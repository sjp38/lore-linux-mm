Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AADAF6B04F9
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 02:46:26 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r13so7750625pfd.14
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 23:46:26 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id 140si2472404pge.136.2017.07.31.23.46.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 31 Jul 2017 23:46:25 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [RFC v6 21/62] powerpc: introduce execute-only pkey
In-Reply-To: <87shhgdx5i.fsf@linux.vnet.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com> <1500177424-13695-22-git-send-email-linuxram@us.ibm.com> <87shhgdx5i.fsf@linux.vnet.ibm.com>
Date: Tue, 01 Aug 2017 16:46:22 +1000
Message-ID: <87d18fu6o1.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>, Ram Pai <linuxram@us.ibm.com>
Cc: linux-arch@vger.kernel.org, corbet@lwn.net, arnd@arndb.de, linux-doc@vger.kernel.org, x86@kernel.org, dave.hansen@intel.com, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, mingo@redhat.com, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, linux-kselftest@vger.kernel.org, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, khandual@linux.vnet.ibm.com

Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com> writes:
> Ram Pai <linuxram@us.ibm.com> writes:
...
>> +
>> +	/* We got one, store it and use it from here on out */
>> +	if (need_to_set_mm_pkey)
>> +		mm->context.execute_only_pkey = execute_only_pkey;
>> +	return execute_only_pkey;
>> +}
>
> If you follow the code flow in __execute_only_pkey, the AMR and UAMOR
> are read 3 times in total, and AMR is written twice. IAMR is read and
> written twice. Since they are SPRs and access to them is slow (or isn't
> it?),

SPRs read/writes are slow, but they're not *that* slow in comparison to
a system call (which I think is where this code is being called?).

So we should try to avoid too many SPR read/writes, but at the same time
we can accept more than the minimum if it makes the code much easier to
follow.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
