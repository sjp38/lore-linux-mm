Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 06BC66B0005
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 16:08:20 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id j14-v6so11952363wrq.4
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 13:08:19 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m14-v6si39153942wrf.250.2018.06.11.13.08.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jun 2018 13:08:18 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5BK3ovN177724
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 16:08:16 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2jhx6ev61a-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 16:08:16 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Mon, 11 Jun 2018 21:08:14 +0100
Date: Mon, 11 Jun 2018 13:08:07 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: pkeys on POWER: Access rights not reset on execve
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <20180603201832.GA10109@ram.oc3035372033.ibm.com>
 <4e53b91f-80a7-816a-3e9b-56d7be7cd092@redhat.com>
 <20180604140135.GA10088@ram.oc3035372033.ibm.com>
 <f2f61c24-8e8f-0d36-4e22-196a2a3f7ca7@redhat.com>
 <20180604190229.GB10088@ram.oc3035372033.ibm.com>
 <30040030-1aa2-623b-beec-dd1ceb3eb9a7@redhat.com>
 <20180608023441.GA5573@ram.oc3035372033.ibm.com>
 <2858a8eb-c9b5-42ce-5cfc-74a4b3ad6aa9@redhat.com>
 <20180611172305.GB5697@ram.oc3035372033.ibm.com>
 <30f5cb0e-e09a-15e6-f77d-a3afa422a651@redhat.com>
MIME-Version: 1.0
In-Reply-To: <30f5cb0e-e09a-15e6-f77d-a3afa422a651@redhat.com>
Message-Id: <20180611200807.GA5773@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>

On Mon, Jun 11, 2018 at 07:29:33PM +0200, Florian Weimer wrote:
> On 06/11/2018 07:23 PM, Ram Pai wrote:
> >On Fri, Jun 08, 2018 at 07:53:51AM +0200, Florian Weimer wrote:
> >>On 06/08/2018 04:34 AM, Ram Pai wrote:
> >>>>
> >>>>So the remaining question at this point is whether the Intel
> >>>>behavior (default-deny instead of default-allow) is preferable.
> >>>
> >>>Florian, remind me what behavior needs to fixed?
> >>
> >>See the other thread.  The Intel register equivalent to the AMR by
> >>default disallows access to yet-unallocated keys, so that threads
> >>which are created before key allocation do not magically gain access
> >>to a key allocated by another thread.
> >
> >Are you referring to the thread
> >'[PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change signal semantics'
> 
> >Otherwise please point me to the URL of that thread. Sorry and thankx. :)
> 
> No, it's this issue:
> 
>   ...

Ok. try this patch. This patch is on top of the 5 patches that I had
sent last week i.e  "[PATCH  0/5] powerpc/pkeys: fixes to pkeys"

The following is a draft patch though to check if it meets your
expectations.

commit fe53b5fe2dcb3139ea27ade3ae7cbbe43c4af3be
Author: Ram Pai <linuxram@us.ibm.com>
Date:   Mon Jun 11 14:57:34 2018 -0500

    powerpc/pkeys: Deny read/write/execute by default
    
    Deny everything for all keys; with some exceptions. Do not do this for
    pkey-0, or else everything will come to a screaching halt.  Also by
    default, do not deny execute for execute-only key.
    
    This is a draft-patch for now.
    
    Signed-off-by: Ram Pai <linuxram@us.ibm.com>

diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index 8225263..289aafd 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -128,13 +128,13 @@ int pkey_initialize(void)
 
 	/* register mask is in BE format */
 	pkey_amr_mask = ~0x0ul;
-	pkey_iamr_mask = ~0x0ul;
+	pkey_amr_mask &= ~(0x3ul << pkeyshift(PKEY_0));
+	pkey_amr_mask &= ~(0x3ul << pkeyshift(1));
 
-	for (i = 0; i < (pkeys_total - os_reserved); i++) {
-		pkey_amr_mask &= ~(0x3ul << pkeyshift(i));
-		pkey_iamr_mask &= ~(0x1ul << pkeyshift(i));
-	}
-	pkey_amr_mask |= (AMR_RD_BIT|AMR_WR_BIT) << pkeyshift(EXECUTE_ONLY_KEY);
+	pkey_iamr_mask = ~0x0ul;
+	pkey_iamr_mask &= ~(0x3ul << pkeyshift(PKEY_0));
+	pkey_iamr_mask &= ~(0x3ul << pkeyshift(1));
+	pkey_iamr_mask &= ~(0x3ul << pkeyshift(EXECUTE_ONLY_KEY));
 
 	pkey_uamor_mask = ~0x0ul;
 	pkey_uamor_mask &= ~(0x3ul << pkeyshift(PKEY_0));

-- 
Ram Pai
