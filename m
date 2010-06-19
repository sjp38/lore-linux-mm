Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CFB476B01CA
	for <linux-mm@kvack.org>; Sat, 19 Jun 2010 13:45:13 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o5JHj8lN006100
	for <linux-mm@kvack.org>; Sat, 19 Jun 2010 10:45:08 -0700
Received: from gwj20 (gwj20.prod.google.com [10.200.10.20])
	by wpaz9.hot.corp.google.com with ESMTP id o5JHj66K003216
	for <linux-mm@kvack.org>; Sat, 19 Jun 2010 10:45:07 -0700
Received: by gwj20 with SMTP id 20so2216850gwj.11
        for <linux-mm@kvack.org>; Sat, 19 Jun 2010 10:45:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100619104439.GA7659@lst.de>
References: <1276907415-504-1-git-send-email-mrubin@google.com>
	<1276907415-504-2-git-send-email-mrubin@google.com> <20100619104439.GA7659@lst.de>
From: Michael Rubin <mrubin@google.com>
Date: Sat, 19 Jun 2010 10:44:46 -0700
Message-ID: <AANLkTimawKkDNpaVrfQtfxPah3QduodLK2njWLTMOhMl@mail.gmail.com>
Subject: Re: [PATCH 1/3] writeback: Creating /sys/kernel/mm/writeback/writeback
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@lst.de>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, jack@suse.cz, akpm@linux-foundation.org, david@fromorbit.com, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

Thanks for looking at this.

On Sat, Jun 19, 2010 at 3:44 AM, Christoph Hellwig <hch@lst.de> wrote:
> I'm fine with exposting this. but the interface is rather awkward.
> These kinds of multiple value per file interface require addition
> parsing and are a pain to extend. =A0Please do something like
>
> /proc/sys/vm/writeback/
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pages_dirtied
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pages_cleaned
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dirty_threshold
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0background_threshold
>
> where you can just read the value from the file.

Cool. This is kind of funny. In the google tree I implemented this in
the same multi-file-one-value-in-file manner. The debate on one file
for all vs that style was heated. And I changed it before sending
upstream. I really don't care either way. So I will just change the
patch and move the values to that location

Do you mind explaining why something would go in /proc/ vs /sys? I
thought the idea was to not put things in /proc anymore.

>> diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
>> index c920164..84b0181 100644
>> --- a/fs/nilfs2/segment.c
>> +++ b/fs/nilfs2/segment.c
>> @@ -1598,8 +1598,10 @@ nilfs_copy_replace_page_buffers(struct page *page=
, struct list_head *out)
>> =A0 =A0 =A0 } while (bh =3D bh->b_this_page, bh2 =3D bh2->b_this_page, b=
h !=3D head);
>> =A0 =A0 =A0 kunmap_atomic(kaddr, KM_USER0);
>>
>> - =A0 =A0 if (!TestSetPageWriteback(clone_page))
>> + =A0 =A0 if (!TestSetPageWriteback(clone_page)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 inc_zone_page_state(clone_page, NR_WRITEBACK=
);
>> + =A0 =A0 =A0 =A0 =A0 =A0 inc_zone_page_state(clone_page, NR_PAGES_ENTER=
ED_WRITEBACK);
>> + =A0 =A0 }
>> =A0 =A0 =A0 unlock_page(clone_page);
>
> I'm not very happy about having this opencoded in a filesystem.

I wasn't excited about this section either. What does opencoded mean?
Do you mean it should not be exposed to specific fs code?

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
