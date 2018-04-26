Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D02286B0006
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 13:57:33 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id o9so13657432pgv.8
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 10:57:33 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id x12si1563828pgv.389.2018.04.26.10.57.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 10:57:32 -0700 (PDT)
Subject: Re: [PATCH 4/9] x86, pkeys: override pkey when moving away from
 PROT_EXEC
References: <20180326172721.D5B2CBB4@viggo.jf.intel.com>
 <20180326172727.025EBF16@viggo.jf.intel.com>
 <20180407000943.GA15890@ram.oc3035372033.ibm.com>
 <6e3f8e1c-afed-64de-9815-8478e18532aa@intel.com>
 <20180407010919.GB15890@ram.oc3035372033.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <aedcb0b6-73f5-f72f-742e-b417131895d3@intel.com>
Date: Thu, 26 Apr 2018 10:57:31 -0700
MIME-Version: 1.0
In-Reply-To: <20180407010919.GB15890@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, shakeelb@google.com, stable@kernel.org, tglx@linutronix.de, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org

On 04/06/2018 06:09 PM, Ram Pai wrote:
> Well :). my point is add this code and delete the other
> code that you add later in that function.

I don't think I'm understanding what your suggestion was.  I looked at
the code and I honestly do not think I can remove any of it.

For the plain (non-explicit pkey_mprotect()) case, there are exactly
four paths through __arch_override_mprotect_pkey(), resulting in three
different results.

1. New prot==PROT_EXEC, no pkey-exec support -> do not override
2. New prot!=PROT_EXEC, old VMA not PROT_EXEC-> do not override
3. New prot==PROT_EXEC, w/ pkey-exec support -> override to exec pkey
4. New prot!=PROT_EXEC, old VMA is PROT_EXEC -> override to default

I don't see any redundancy there, or any code that we can eliminate or
simplify.  It was simpler before, but that's what where bug was.
