Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D3C636B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 12:36:47 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t4-v6so6299888pgv.21
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 09:36:47 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id z4si7922103pff.159.2018.04.30.09.36.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Apr 2018 09:36:46 -0700 (PDT)
Subject: Re: [PATCH 4/9] x86, pkeys: override pkey when moving away from
 PROT_EXEC
References: <20180326172721.D5B2CBB4@viggo.jf.intel.com>
 <20180326172727.025EBF16@viggo.jf.intel.com>
 <20180407000943.GA15890@ram.oc3035372033.ibm.com>
 <6e3f8e1c-afed-64de-9815-8478e18532aa@intel.com>
 <20180407010919.GB15890@ram.oc3035372033.ibm.com>
 <aedcb0b6-73f5-f72f-742e-b417131895d3@intel.com>
 <20180430075106.GA5666@ram.oc3035372033.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <54b94b65-807d-ebc5-ccfd-30eef1873faf@intel.com>
Date: Mon, 30 Apr 2018 09:36:44 -0700
MIME-Version: 1.0
In-Reply-To: <20180430075106.GA5666@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, shakeelb@google.com, stable@kernel.org, tglx@linutronix.de, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org

On 04/30/2018 12:51 AM, Ram Pai wrote:
> 	/*
> 	 * Look for a protection-key-drive execute-only mapping
> 	 * which is now being given permissions that are not
> 	 * execute-only.  Move it back to the default pkey.
> 	 */
> 	if (vma_is_pkey_exec_only(vma) && (prot != PROT_EXEC)) <--------
> 		return ARCH_DEFAULT_PKEY;
> 
> 	/*
> 	 * The mapping is execute-only.  Go try to get the
> 	 * execute-only protection key.  If we fail to do that,
> 	 * fall through as if we do not have execute-only
> 	 * support.
> 	 */
> 	if (prot == PROT_EXEC) {
> 		pkey = execute_only_pkey(vma->vm_mm);
> 		if (pkey > 0)
> 			return pkey;
> 	}

Yes, that would also work.  It's just a matter of whether you prefer
having the prot==PROT_EXEC checks in one place or two.  I'd rather leave
it the way I've got it unless there are major objections since it's been
tested.
