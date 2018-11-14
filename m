Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4FBC86B0003
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 13:04:54 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id 194-v6so5620356ywp.12
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 10:04:54 -0800 (PST)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id q202-v6si14309962ywg.119.2018.11.14.10.04.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 10:04:52 -0800 (PST)
Subject: Re: [PATCH] Fix do_move_pages_to_node() error handling
References: <20181114004059.1287439-1-pjaroszynski@nvidia.com>
 <20181114073415.GD23419@dhcp22.suse.cz>
 <20181114112945.GQ23419@dhcp22.suse.cz>
From: Piotr Jaroszynski <pjaroszynski@nvidia.com>
Message-ID: <ddf79812-7702-d513-3f83-70bba1b258db@nvidia.com>
Date: Wed, 14 Nov 2018 10:04:45 -0800
MIME-Version: 1.0
In-Reply-To: <20181114112945.GQ23419@dhcp22.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, p.jaroszynski@gmail.com
Cc: linux-mm@kvack.org, Jan Stancek <jstancek@redhat.com>

On 11/14/18 3:29 AM, Michal Hocko wrote:
> On Wed 14-11-18 08:34:15, Michal Hocko wrote:
>> On Tue 13-11-18 16:40:59, p.jaroszynski@gmail.com wrote:
>>> From: Piotr Jaroszynski <pjaroszynski@nvidia.com>
>>>
>>> migrate_pages() can return the number of pages that failed to migrate
>>> instead of 0 or an error code. If that happens, the positive return is
>>> treated as an error all the way up through the stack leading to the
>>> move_pages() syscall returning a positive number. I believe this
>>> regressed with commit a49bd4d71637 ("mm, numa: rework do_pages_move")
>>> that refactored a lot of this code.
>>
>> Yes this is correct.
>>
>>> Fix this by treating positive returns as success in
>>> do_move_pages_to_node() as that seems to most closely follow the
>>> previous code. This still leaves the question whether silently
>>> considering this case a success is the right thing to do as even the
>>> status of the pages will be set as if they were successfully migrated,
>>> but that seems to have been the case before as well.
>>
>> Yes, I believe the previous semantic was just wrong and we want to fix
>> it. Jan has already brought this up [1]. I believe we want to update the
>> documentation rather than restore the previous hazy semantic.

That's probably fair although at least some code we have will have to be
updated as it just checks for non-zero returns from move_pages() and
assumes errno is set when that happens.

>>
>> Just wondering, how have you found out? Is there any real application
>> failing because of the change or this is a result of some test?

I have a test that creates a tmp file, mmaps it as shared, memsets the
memory and then attempts to move it to a different node. It used to
work, but now fails. I suspect the filesystem's migratepage() callback
regressed and will look into it next. So far I have only tested this on
powerpc with the xfs filesystem.

>>
>> [1] http://lkml.kernel.org/r/0329efa0984b9b0252ef166abb4498c0795fab36.1535113317.git.jstancek@redhat.com
> 
> Btw. this is what I was suggesting back then (along with the man page
> update suggested by Jan)
> 
> From cfb88c266b645197135cde2905c2bfc82f6d82a9 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Wed, 14 Nov 2018 12:19:09 +0100
> Subject: [PATCH] mm: fix do_pages_move error reporting
> 
> a49bd4d71637 ("mm, numa: rework do_pages_move") has changed the way how
> we report error to layers above. As the changelog mentioned the semantic
> was quite unclear previously because the return 0 could mean both
> success and failure.
> 
> The above mentioned commit didn't get all the way down to fix this
> completely because it doesn't report pages that we even haven't
> attempted to migrate and therefore we cannot simply say that the
> semantic is:
> - err < 0 - errno
> - err >= 0 number of non-migrated pages.
> 
> Fixes: a49bd4d71637 ("mm, numa: rework do_pages_move")
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/migrate.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index f7e4bfdc13b7..aa53ebc523eb 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1615,8 +1615,16 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
>  			goto out_flush;
>  
>  		err = do_move_pages_to_node(mm, &pagelist, current_node);
> -		if (err)
> +		if (err) {
> +			/*
> +			 * Possitive err means the number of failed pages to
> +			 * migrate. Make sure to report the rest of the
> +			 * nr_pages is not migrated as well.
> +			 */
> +			if (err > 0)
> +				err += nr_pages - i - 1;
>  			goto out;

Ok, so we give up after the first failure to migrate everything. That
probably makes sense although I don't have a good idea about how
frequent it is for the migration to give up in such a manner (short of
the issue I'm seeing that I suspect is a separate bug). In this case,
should the status of each page be updated to something instead of being
left undefined? Or should it be specified that page status is only valid
for the first N - not migrated pages?

> +		}
>  		if (i > start) {
>  			err = store_status(status, start, current_node, i - start);
>  			if (err)
> 
