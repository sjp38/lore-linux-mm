Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id AC6346B0009
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 13:53:39 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 1-v6so13474659plv.6
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 10:53:39 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id b6-v6si6162904plm.202.2018.03.26.10.53.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 10:53:38 -0700 (PDT)
Subject: Re: [PATCH 1/9] x86, pkeys: do not special case protection key 0
References: <20180326172721.D5B2CBB4@viggo.jf.intel.com>
 <20180326172722.8CC08307@viggo.jf.intel.com>
 <9c2de5f6-d9e2-3647-7aa8-86102e9fa6c3@kernel.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <b54257c2-138c-7ac9-8176-0dc4868093ef@intel.com>
Date: Mon, 26 Mar 2018 10:53:35 -0700
MIME-Version: 1.0
In-Reply-To: <9c2de5f6-d9e2-3647-7aa8-86102e9fa6c3@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shuah Khan <shuah@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, stable@kernel.org, linuxram@us.ibm.com, tglx@linutronix.de, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, Shuah Khan <shuahkh@osg.samsung.com>

On 03/26/2018 10:47 AM, Shuah Khan wrote:
> 
> Also what happens "pkey_free() pkey-0" - can you elaborate more on that
> "silliness consequences"

It's just what happens if you free any other pkey that is in use: it
might get reallocated later.  The most likely scenario is that you will
get pkey-0 back from pkey_alloc(), you will set an access-disable or
write-disable bit in PKRU for it, and your next stack access will SIGSEGV.
