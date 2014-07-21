Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6B07E6B003B
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 14:36:42 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id fp1so9623852pdb.19
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 11:36:42 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id tw6si5140178pac.205.2014.07.21.11.36.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 11:36:41 -0700 (PDT)
Date: Mon, 21 Jul 2014 14:33:31 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [RFC PATCH 0/11] Support Write-Through mapping on x86
Message-ID: <20140721183331.GB13420@laptop.dumpdata.com>
References: <1405452884-25688-1-git-send-email-toshi.kani@hp.com>
 <53C58A69.3070207@zytor.com>
 <1405459404.28702.17.camel@misato.fc.hp.com>
 <03d059f5-b564-4530-9184-f91ca9d5c016@email.android.com>
 <1405546127.28702.85.camel@misato.fc.hp.com>
 <1405960298.30151.10.camel@misato.fc.hp.com>
 <53CD443A.6050804@zytor.com>
 <1405962993.30151.35.camel@misato.fc.hp.com>
 <53CD4EB2.5020709@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53CD4EB2.5020709@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Toshi Kani <toshi.kani@hp.com>, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, plagnioj@jcrosoft.com, tomi.valkeinen@ti.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, airlied@gmail.com, bp@alien8.de

On Mon, Jul 21, 2014 at 10:32:34AM -0700, H. Peter Anvin wrote:
> On 07/21/2014 10:16 AM, Toshi Kani wrote:
> > 
> > You are right.  I was under a wrong impression that
> > __change_page_attr() always splits a large pages into 4KB pages, but I
> > overlooked the fact that it can handle a large page as well.  So, this
> > approach does not work...
> > 
> 
> If it did it would be a major fail.
> 
> >> I would also like a systematic way to deal with the fact
> >> that Xen (sigh) is stuck with a separate mapping system.
> >>
> >> I guess Linux could adopt the Xen mappings if that makes it easier, as
> >> long as that doesn't have a negative impact on native hardware -- we can
> >> possibly deal with some older chips not being optimal.  
> > 
> > I see.  I agree that supporting the PAT bit is the right direction, but
> > I do not know how much effort we need.  I will study on this.
> > 
> >> However, my thinking has been to have a "reverse PAT" table in memory of memory
> >> types to encodings, both for regular and large pages.
> > 
> > I am not clear about your idea of the "reverse PAT" table.  Would you
> > care to elaborate?  How is it different from using pte_val() being a
> > paravirt function on Xen?
> 
> First of all, paravirt functions are the root of all evil, and we want

Here I was thinking to actually put an entry in the MAINTAINERS
file for me to become the owner of it - as the folks listed there
are busy with other things.

The Maintainer of 'All Evil' has an interesting ring to it :-)

> to reduce and eliminate them to the utmost level possible.  But yes, we
> could plumb that up that way if we really need to.
> 
> What I'm thinking of is a table which can deal with both the moving PTE
> bit, Xen, and the scattered encodings by having a small table from types
> to encodings, and not use the encodings directly until fairly late it
> the pipe.  I suspect, but I'm not sure, that we would also need the
> inverse operation.

Mr Toshi-san,

This link: http://xenbits.xen.org/gitweb/?p=xen.git;a=blob;f=xen/arch/x86/hvm/mtrr.c;h=ee18553cdac58dd16836011ee714517fbc16368d;hb=HEAD#l74 might help you in figuring how this can be done.

Thought I have to say that the code is quite complex so it might
be more confusing then helpful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
