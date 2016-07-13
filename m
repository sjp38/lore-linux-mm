Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D75826B0260
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 09:47:19 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f126so36082492wma.3
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 06:47:19 -0700 (PDT)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id x17si1730815wmd.115.2016.07.13.06.47.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 06:47:18 -0700 (PDT)
Received: by mail-wm0-f47.google.com with SMTP id o80so70162201wme.1
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 06:47:18 -0700 (PDT)
Date: Wed, 13 Jul 2016 15:47:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Page Allocation Failures/OOM with dm-crypt on software RAID10
 (Intel Rapid Storage)
Message-ID: <20160713134717.GL28723@dhcp22.suse.cz>
References: <02580b0a303da26b669b4a9892624b13@mail.ud19.udmedia.de>
 <20160712095013.GA14591@dhcp22.suse.cz>
 <d9dbe0328e938eb7544fdb2aa8b5a9c7@mail.ud19.udmedia.de>
 <20160712114920.GF14586@dhcp22.suse.cz>
 <e6c2087730e530e77c2b12d50495bdc9@mail.ud19.udmedia.de>
 <20160712140715.GL14586@dhcp22.suse.cz>
 <459d501038de4d25db6d140ac5ea5f8d@mail.ud19.udmedia.de>
 <20160713112126.GH28723@dhcp22.suse.cz>
 <20160713121828.GI28723@dhcp22.suse.cz>
 <74b9325c37948cf2b460bd759cff23dd@mail.ud19.udmedia.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <74b9325c37948cf2b460bd759cff23dd@mail.ud19.udmedia.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Dahl <ml_linux-kernel@binary-island.eu>
Cc: linux-raid@vger.kernel.org, linux-mm@kvack.org, dm-devel@redhat.com, linux-kernel@vger.kernel.org, Mike Snitzer <snitzer@redhat.com>

On Wed 13-07-16 15:18:11, Matthias Dahl wrote:
> Hello Michal,
> 
> many thanks for all your time and help on this issue. It is very much
> appreciated and I hope we can track this down somehow.
> 
> On 2016-07-13 14:18, Michal Hocko wrote:
> 
> > So it seems we are accumulating bios and 256B objects. Buffer heads as
> > well but so much. Having over 4G worth of bios sounds really suspicious.
> > Note that they pin pages to be written so this might be consuming the
> > rest of the unaccounted memory! So the main question is why those bios
> > do not get dispatched or finished.
> 
> Ok. It is the Block IOs that do not get completed. I do get it right
> that those bio-3 are already the encrypted data that should be written
> out but do not for some reason?

Hard to tell. Maybe they are just allocated and waiting for encryption.
But this is just a wild guessing.


> I tried to figure this out myself but
> couldn't find anything -- what does the number "-3" state? It is the
> position in some chain or has it a different meaning?

$ git grep "kmem_cache_create.*bio"
block/bio-integrity.c:  bip_slab = kmem_cache_create("bio_integrity_payload",

so there doesn't seem to be any cache like that in the vanilla kernel.

> Do you think a trace like you mentioned would help shed some more light
> on this? Or would you recommend something else?

Dunno. Seeing who is allocating those bios might be helpful but it won't
tell much about what has happened to them after allocation. The tracing
would be more helpful for a mem leak situation which doesn't seem to be
the case here.

This is getting out of my area of expertise so I am not sure I can help
you much more, I am afraid.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
