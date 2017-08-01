Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 427B36B0565
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 12:14:23 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id a186so22180831pge.7
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 09:14:23 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b99si11259998pli.731.2017.08.01.09.14.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 09:14:21 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v71GAkSi046016
	for <linux-mm@kvack.org>; Tue, 1 Aug 2017 12:14:21 -0400
Received: from e24smtp02.br.ibm.com (e24smtp02.br.ibm.com [32.104.18.86])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2c2v82a6gg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 01 Aug 2017 12:14:21 -0400
Received: from localhost
	by e24smtp02.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bauerman@linux.vnet.ibm.com>;
	Tue, 1 Aug 2017 13:14:18 -0300
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay03.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v71GEEZb26476756
	for <linux-mm@kvack.org>; Tue, 1 Aug 2017 13:14:14 -0300
Received: from d24av01.br.ibm.com (localhost [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v71GEEI6004304
	for <linux-mm@kvack.org>; Tue, 1 Aug 2017 13:14:14 -0300
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com> <1500177424-13695-22-git-send-email-linuxram@us.ibm.com> <87shhgdx5i.fsf@linux.vnet.ibm.com> <87d18fu6o1.fsf@concordia.ellerman.id.au>
From: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Subject: Re: [RFC v6 21/62] powerpc: introduce execute-only pkey
In-reply-to: <87d18fu6o1.fsf@concordia.ellerman.id.au>
Date: Tue, 01 Aug 2017 13:14:02 -0300
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87d18fw9it.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Ram Pai <linuxram@us.ibm.com>, linux-arch@vger.kernel.org, corbet@lwn.net, arnd@arndb.de, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, dave.hansen@intel.com, mingo@redhat.com, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, linux-kselftest@vger.kernel.org, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, khandual@linux.vnet.ibm.com


Michael Ellerman <mpe@ellerman.id.au> writes:

> Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com> writes:
>> Ram Pai <linuxram@us.ibm.com> writes:
> ...
>>> +
>>> +	/* We got one, store it and use it from here on out */
>>> +	if (need_to_set_mm_pkey)
>>> +		mm->context.execute_only_pkey = execute_only_pkey;
>>> +	return execute_only_pkey;
>>> +}
>>
>> If you follow the code flow in __execute_only_pkey, the AMR and UAMOR
>> are read 3 times in total, and AMR is written twice. IAMR is read and
>> written twice. Since they are SPRs and access to them is slow (or isn't
>> it?),
>
> SPRs read/writes are slow, but they're not *that* slow in comparison to
> a system call (which I think is where this code is being called?).

Yes, this code runs on mprotect and mmap syscalls if the memory is
requested to have execute but not read nor write permissions.

> So we should try to avoid too many SPR read/writes, but at the same time
> we can accept more than the minimum if it makes the code much easier to
> follow.

Ok. Ram had asked me to suggest a way to optimize the SPR reads and
writes and I came up with the patch below. Do you think it's worth it?

The patch applies on top of this series, but if Ram includes it I think
he would break it up and merge it into the other patches.

-- 
Thiago Jung Bauermann
IBM Linux Technology Center
