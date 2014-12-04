Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8319B6B0032
	for <linux-mm@kvack.org>; Wed,  3 Dec 2014 21:33:52 -0500 (EST)
Received: by mail-oi0-f43.google.com with SMTP id a3so11826868oib.16
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 18:33:52 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id fn9si6514322obb.12.2014.12.03.18.33.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 03 Dec 2014 18:33:51 -0800 (PST)
Message-ID: <547FC807.6040000@oracle.com>
Date: Wed, 03 Dec 2014 21:33:43 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: shmem: avoid overflowing in shmem_fallocate
References: <1417652657-1801-1-git-send-email-sasha.levin@oracle.com> <20141204015120.GA2522@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20141204015120.GA2522@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 12/03/2014 08:51 PM, Naoya Horiguchi wrote:
> On Wed, Dec 03, 2014 at 07:24:07PM -0500, Sasha Levin wrote:
>> > "offset + len" has the potential of overflowing. Validate this user input
>> > first to avoid undefined behaviour.
>> > 
>> > Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
>> > ---
>> >  mm/shmem.c |    3 +++
>> >  1 file changed, 3 insertions(+)
>> > 
>> > diff --git a/mm/shmem.c b/mm/shmem.c
>> > index 185836b..5a0e344 100644
>> > --- a/mm/shmem.c
>> > +++ b/mm/shmem.c
>> > @@ -2098,6 +2098,9 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
>> >  	}
>> >  
>> >  	/* We need to check rlimit even when FALLOC_FL_KEEP_SIZE */
>> > +	error = -EOVERFLOW;
>> > +	if ((u64)len + offset < (u64)len)
>> > +		goto out;
> Hi Sasha,
> 
> It seems to me that we already do some overflow check in common path,
> do_fallocate():
> 
>         /* Check for wrap through zero too */
>         if (((offset + len) > inode->i_sb->s_maxbytes) || ((offset + len) < 0))
>                 return -EFBIG;
> 
> Do we really need another check?

It looks like we actually need to fix this snippet you pasted rather than shmem_fallocate().

We can't check for ((offset + len) < 0) since both offset and length are signed integers. I'll
send a patch to deal with that rather that this shmem specific one. Thanks!


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
