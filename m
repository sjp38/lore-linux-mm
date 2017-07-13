Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3DC70440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 03:39:59 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id q87so46693916pfk.15
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 00:39:59 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j10si3937093plg.201.2017.07.13.00.39.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 00:39:58 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6D7csLa001291
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 03:39:57 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bnt3r44pc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 03:39:57 -0400
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Thu, 13 Jul 2017 03:39:55 -0400
Date: Thu, 13 Jul 2017 00:39:41 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [RFC v5 02/38] powerpc: Free up four 64K PTE bits in 64K backed
 HPTE pages
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
 <1499289735-14220-3-git-send-email-linuxram@us.ibm.com>
 <20170711155959.79e2d4de@firefly.ozlabs.ibm.com>
 <20170711154415.GA5525@ram.oc3035372033.ibm.com>
 <20170712131051.5bf657c7@firefly.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170712131051.5bf657c7@firefly.ozlabs.ibm.com>
Message-Id: <20170713073941.GE5525@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On Wed, Jul 12, 2017 at 01:10:51PM +1000, Balbir Singh wrote:
> On Tue, 11 Jul 2017 08:44:15 -0700
> Ram Pai <linuxram@us.ibm.com> wrote:
> 
> > On Tue, Jul 11, 2017 at 03:59:59PM +1000, Balbir Singh wrote:
> > > On Wed,  5 Jul 2017 14:21:39 -0700
> > > Ram Pai <linuxram@us.ibm.com> wrote:
> > >   
> > > > Rearrange 64K PTE bits to  free  up  bits 3, 4, 5  and  6
> > > > in the 64K backed HPTE pages. This along with the earlier
> > > > patch will  entirely free  up the four bits from 64K PTE.
> > > > The bit numbers are  big-endian as defined in the  ISA3.0
> > > > 
> > > > This patch  does  the  following change to 64K PTE backed
> > > > by 64K HPTE.
> > > > 
> > > > H_PAGE_F_SECOND (S) which  occupied  bit  4  moves to the
> > > > 	second part of the pte to bit 60.
> > > > H_PAGE_F_GIX (G,I,X) which  occupied  bit 5, 6 and 7 also
> > > > 	moves  to  the   second part of the pte to bit 61,
> > > >        	62, 63, 64 respectively
> > > > 
> > > > since bit 7 is now freed up, we move H_PAGE_BUSY (B) from
> > > > bit  9  to  bit  7.
> > > > 
> > > > The second part of the PTE will hold
> > > > (H_PAGE_F_SECOND|H_PAGE_F_GIX) at bit 60,61,62,63.
> > > > 
> > > > Before the patch, the 64K HPTE backed 64k PTE format was
> > > > as follows
> > > > 
> > > >  0 1 2 3 4  5  6  7  8 9 10...........................63
> > > >  : : : : :  :  :  :  : : :                            :
> > > >  v v v v v  v  v  v  v v v                            v
> > > > 
> > > > ,-,-,-,-,--,--,--,--,-,-,-,-,-,------------------,-,-,-,
> > > > |x|x|x| |S |G |I |X |x|B|x|x|x|................|.|.|.|.| <- primary pte
> > > > '_'_'_'_'__'__'__'__'_'_'_'_'_'________________'_'_'_'_'
> > > > | | | | |  |  |  |  | | | | |..................| | | | | <- secondary pte
> > > > '_'_'_'_'__'__'__'__'_'_'_'_'__________________'_'_'_'_'
> > > >  
> > > 
> > > It's not entirely clear what the secondary pte contains
> > > today and how many of the bits are free today?  
> > 
> > The secondary pte today is not used for anything for 64k-hpte
> > backed ptes. It gets used the moment the pte gets backed by
> > 4-k hptes. Till then the bits are available. And this patch
> > makes use of that knowledge. 
> 
> OK.. but does this mean subpage-protection? Or do you mean
> page size demotion? I presume it's the later.

Yes. the later.
RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
