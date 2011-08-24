Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B28786B0169
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 11:05:12 -0400 (EDT)
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1QwF0s-0006ut-7R
	for linux-mm@kvack.org; Wed, 24 Aug 2011 17:05:08 +0200
Received: from 125.19.39.117 ([125.19.39.117])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 24 Aug 2011 17:05:06 +0200
Received: from consul.kautuk by 125.19.39.117 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 24 Aug 2011 17:05:06 +0200
From: Kautuk Consul <consul.kautuk@gmail.com>
Subject: Re: [PATCH] ARM: sparsemem: Enable =?utf-8?b?Q09ORklHX0hPTEVTX0lOX1pPTkU=?= config option for SparseMem and =?utf-8?b?SEFTX0hPTEVTX01FTU9SWU1PREVM?= for linux-3.0.
Date: Wed, 24 Aug 2011 12:31:51 +0000 (UTC)
Message-ID: <loom.20110824T142225-279@post.gmane.org>
References: <CAFPAmTQByL0YJT8Lvar1Oe+3Q1EREvqPA_GP=hHApJDz5dSOzQ@mail.gmail.com> <20110803110555.GD19099@suse.de> <CAFPAmTR79S3AVXrAFL5bMkhs2droL8THUCCPY23Ar5x_oftheQ@mail.gmail.com> <20110803132839.GG19099@suse.de> <CAFPAmTS2JEVk3tWhJN034dUmaxLujswmmsqGABGYEV=N3v0Ehw@mail.gmail.com> <20110804100928.GN19099@suse.de> <CAFPAmTQir8HnP2=WwPGSaWFu=hBS9=xT88f+XFFx5Hdf6zvGTA@mail.gmail.com> <20110805084742.GU19099@suse.de> <CAFPAmTS8-qQ4ZzBeJeKuG2jvyyfkwnqbtSjPX2TLddDPtSmF7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


Hi Mel,


Kautuk Consul <consul.kautuk <at> gmail.com> writes:

> 
> Ok, I analyzed the code and it seems that this alignment problem has
> been solved by the changes made
> to the free_unused_memmap() code in arch/arm/mm/init.c.
> 
> I backported those changes to free_unused_memmap_node() in
> linux-2.6.35.9 and I don't see any more
> crashes. This solves my problem.
> 
> Thanks for all the help.


As per the email below, you might remember that I found a temporary 
solution by back-porting the free_unused_memmap_node() function in the 
arch/arm code.

The original issue was a crash in the move_freepages() function. 
The crash was happening because the pageblock pages was partially 
within one memory bank.

Can we solve this issue by modifying the check in move_freepages_block()
in the following manner: 
if (end_pfn >= zone->zone_start_pfn + zone->spanned_pages || 
    !PageBuddy(end_page))
    return 0;

This should take care of the crash situation as we will return 0 if
the end_page is lying outside a valid memory bank.

Do you agree with this change ?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
