Received: by wa-out-1112.google.com with SMTP id m28so1331960wag.8
        for <linux-mm@kvack.org>; Sun, 08 Jun 2008 14:07:09 -0700 (PDT)
Message-ID: <2f11576a0806081407l5d26d229ye252ff378434e787@mail.gmail.com>
Date: Mon, 9 Jun 2008 06:07:09 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH -mm 13/25] Noreclaim LRU Infrastructure
In-Reply-To: <20080608163413.08d46427@bree.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080606202838.390050172@redhat.com>
	 <20080606202859.291472052@redhat.com>
	 <20080606180506.081f686a.akpm@linux-foundation.org>
	 <20080608163413.08d46427@bree.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

>> > +#ifdef CONFIG_NORECLAIM_LRU
>> > +   PG_noreclaim,           /* Page is "non-reclaimable"  */
>> > +#endif
>>
>> I fear that we're messing up the terminology here.
>>
>> Go into your 2.6.25 tree and do `grep -i reclaimable */*.c'.  The term
>> already means a few different things, but in the vmscan context,
>> "reclaimable" means that the page is unreferenced, clean and can be
>> stolen.  "reclaimable" also means a lot of other things, and we just
>> made that worse.
>>
>> Can we think of a new term which uniquely describes this new concept
>> and use that, rather than flogging the old horse?
>
> Want to reuse the BSD term "pinned" instead?

I like this term :)
but I afraid to somebody confuse Xen/KVM term's pinned page.
IOW, I guess somebody imazine from "pinned page" to below flag.

#define PG_pinned               PG_owner_priv_1 /* Xen pinned pagetable */

I have no idea....


>> > +/**
>> > + * add_page_to_noreclaim_list
>> > + * @page:  the page to be added to the noreclaim list
>> > + *
>> > + * Add page directly to its zone's noreclaim list.  To avoid races with
>> > + * tasks that might be making the page reclaimble while it's not on the
>> > + * lru, we want to add the page while it's locked or otherwise "invisible"
>> > + * to other tasks.  This is difficult to do when using the pagevec cache,
>> > + * so bypass that.
>> > + */
>>
>> How does a task "make a page reclaimable"?  munlock()?  fsync()?
>> exit()?
>>
>> Choice of terminology matters...
>
> Lee?  Kosaki-san?

IFAIK, moving noreclaim list to reclaim list happend at below situation.

mlock'ed page
  - all mlocked process exit.
  - all mlocked process call munlock().
  - page related vma vanished
    (e.g. mumap, mmap, remap_file_page)

SHM_LOCKed page
  -  sysctl(SHM_UNLOCK) called.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
