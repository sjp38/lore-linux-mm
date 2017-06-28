Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id BBA766B02C3
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 03:12:42 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 21so8047790wmt.15
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 00:12:42 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i16si5335076wme.37.2017.06.28.00.12.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 00:12:41 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5S79OmR124881
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 03:12:40 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2bc243ukax-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 03:12:39 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Wed, 28 Jun 2017 01:12:39 -0600
Date: Wed, 28 Jun 2017 00:12:28 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [RFC v4 09/17] powerpc: call the hash functions with the correct
 pkey value
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1498558319-32466-1-git-send-email-linuxram@us.ibm.com>
 <1498558319-32466-10-git-send-email-linuxram@us.ibm.com>
 <5e4fa932-4313-5376-2147-a6431bbec16b@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5e4fa932-4313-5376-2147-a6431bbec16b@linux.vnet.ibm.com>
Message-Id: <20170628071228.GA5561@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On Tue, Jun 27, 2017 at 08:54:07PM +0530, Aneesh Kumar K.V wrote:
> 
> 
> On Tuesday 27 June 2017 03:41 PM, Ram Pai wrote:
> >Pass the correct protection key value to the hash functions on
> >page fault.
> >
> >Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> >---
> >  arch/powerpc/include/asm/pkeys.h | 11 +++++++++++
> >  arch/powerpc/mm/hash_utils_64.c  |  4 ++++
> >  arch/powerpc/mm/mem.c            |  6 ++++++
> >  3 files changed, 21 insertions(+)
> >
> >diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
> >index ef1c601..1370b3f 100644
> >--- a/arch/powerpc/include/asm/pkeys.h
> >+++ b/arch/powerpc/include/asm/pkeys.h
> >@@ -74,6 +74,17 @@ static inline bool mm_pkey_is_allocated(struct mm_struct *mm, int pkey)
> >  }
> >
> >  /*
> >+ * return the protection key of the vma corresponding to the
> >+ * given effective address @ea.
> >+ */
> >+static inline int mm_pkey(struct mm_struct *mm, unsigned long ea)
> >+{
> >+	struct vm_area_struct *vma = find_vma(mm, ea);
> >+	int pkey = vma ? vma_pkey(vma) : 0;
> >+	return pkey;
> >+}
> >+
> >+/*
> >
> 
> That is not going to work in hash fault path right ? We can't do a
> find_vma there without holding the mmap_sem

There is a fundamental problem with this new design. Looks like we can't
hold a lock in that path, without badly hurting the performance.

I am moving back to the old design. Cant by-pass the pte. The
keys will be programmed into the pte which will than be used
to program the hpte.

RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
