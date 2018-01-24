Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C11F1800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 12:52:15 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id o11so2855142pgp.14
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 09:52:15 -0800 (PST)
Received: from relay1.mentorg.com (relay1.mentorg.com. [192.94.38.131])
        by mx.google.com with ESMTPS id j21si408699pgn.142.2018.01.24.09.52.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 09:52:14 -0800 (PST)
Date: Wed, 24 Jan 2018 23:22:07 +0530
From: Balasubramani Vivekanandan <balasubramani_vivekanandan@mentor.com>
Subject: Re: [PATCH] mm/slub.c: Fix wrong address during slab padding
 restoration
Message-ID: <20180124175207.GA7562@bala-ubuntu>
References: <1516604578-4577-1-git-send-email-balasubramani_vivekanandan@mentor.com>
 <20180123145026.b7ca0a338cd0f2de2787b9c1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180123145026.b7ca0a338cd0f2de2787b9c1@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

On Tue, Jan 23, 2018 at 02:50:26PM -0800, Andrew Morton wrote:
> On Mon, 22 Jan 2018 12:32:58 +0530 Balasubramani Vivekanandan <balasubramani_vivekanandan@mentor.com> wrote:
> 
> > From: Balasubramani Vivekanandan <balasubramani_vivekanandan@mentor.com>
> > 
> > Start address calculated for slab padding restoration was wrong.
> > Wrong address would point to some section before padding and
> > could cause corruption
> > 
> > ...
> >
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -838,6 +838,7 @@ static int slab_pad_check(struct kmem_cache *s, struct page *page)
> >  	u8 *start;
> >  	u8 *fault;
> >  	u8 *end;
> > +	u8 *pad;
> >  	int length;
> >  	int remainder;
> >  
> > @@ -851,8 +852,9 @@ static int slab_pad_check(struct kmem_cache *s, struct page *page)
> >  	if (!remainder)
> >  		return 1;
> >  
> > +	pad = end - remainder;
> >  	metadata_access_enable();
> > -	fault = memchr_inv(end - remainder, POISON_INUSE, remainder);
> > +	fault = memchr_inv(pad, POISON_INUSE, remainder);
> >  	metadata_access_disable();
> >  	if (!fault)
> >  		return 1;
> > @@ -860,9 +862,9 @@ static int slab_pad_check(struct kmem_cache *s, struct page *page)
> >  		end--;
> >  
> >  	slab_err(s, page, "Padding overwritten. 0x%p-0x%p", fault, end - 1);
> > -	print_section(KERN_ERR, "Padding ", end - remainder, remainder);
> > +	print_section(KERN_ERR, "Padding ", pad, remainder);
> >  
> > -	restore_bytes(s, "slab padding", POISON_INUSE, end - remainder, end);
> > +	restore_bytes(s, "slab padding", POISON_INUSE, fault, end);
> >  	return 0;
> >  }
> 
> I don't see why it matters?  The current code will overwrite
> POISON_INUSE bytes with POISON_INUSE, won't it?
> 
> That's a bit strange but not incorrect?
Not really. The bug will overwrite into the object area with
POISON_INUSE.
The end pointer initially points to end of the padding area. Then
in the loop, end is decremented till it points to the end of the fault
area.

while (end > fault && end[-1] == POISON_INUSE)
	end--;

Now using end - remainder, will not point to the begining of the padding
area but will sneak into the object area. So restore_bytes will
overwrite the object area

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
