Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 13D7E6B0006
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 22:27:33 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v11so4831906wri.13
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 19:27:33 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 94si395546edk.445.2018.03.26.19.27.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 19:27:31 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2R2OVir081010
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 22:27:29 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gyac65btc-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 22:27:29 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Tue, 27 Mar 2018 03:27:27 +0100
Date: Mon, 26 Mar 2018 19:27:18 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH 1/9] x86, pkeys: do not special case protection key 0
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <20180323180903.33B17168@viggo.jf.intel.com>
 <20180323180905.B40984E6@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180323180905.B40984E6@viggo.jf.intel.com>
Message-Id: <20180327022718.GD5743@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, dave.hansen@intel.com, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org

On Fri, Mar 23, 2018 at 11:09:05AM -0700, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> mm_pkey_is_allocated() treats pkey 0 as unallocated.  That is
> inconsistent with the manpages, and also inconsistent with
> mm->context.pkey_allocation_map.  Stop special casing it and only
> disallow values that are actually bad (< 0).
> 
> The end-user visible effect of this is that you can now use
> mprotect_pkey() to set pkey=0.
> 
> This is a bit nicer than what Ram proposed because it is simpler
> and removes special-casing for pkey 0.  On the other hand, it does
> allow applciations to pkey_free() pkey-0, but that's just a silly
> thing to do, so we are not going to protect against it.

The more I think about this, the more I feel we are opening up a can
of worms.  I am ok with a bad application, shooting itself in its feet.
But I am worried about all the bug reports and support requests we
will encounter when applications inadvertently shoot themselves 
and blame it on the kernel.

a warning in dmesg logs indicating a free-of-pkey-0 can help deflect
the blame from the kernel.

RP
