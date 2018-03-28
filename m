Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C89A26B0012
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 16:47:25 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id m188so2420037qkd.15
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 13:47:25 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v40si380106qth.86.2018.03.28.13.47.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 13:47:24 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2SKjW4Y121584
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 16:47:23 -0400
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h0gf94s9e-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 16:47:22 -0400
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bauerman@linux.vnet.ibm.com>;
	Wed, 28 Mar 2018 14:47:22 -0600
References: <1519264541-7621-1-git-send-email-linuxram@us.ibm.com> <1519264541-7621-8-git-send-email-linuxram@us.ibm.com> <dc5ee0c8-afe3-78aa-001d-7b49b398337b@intel.com>
From: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Subject: Re: [PATCH v12 07/22] selftests/vm: fixed bugs in pkey_disable_clear()
In-reply-to: <dc5ee0c8-afe3-78aa-001d-7b49b398337b@intel.com>
Date: Wed, 28 Mar 2018 17:47:04 -0300
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87muys3p2v.fsf@morokweng.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, ebiederm@xmission.com, arnd@arndb.de


Dave Hansen <dave.hansen@intel.com> writes:

> On 02/21/2018 05:55 PM, Ram Pai wrote:
>> --- a/tools/testing/selftests/vm/protection_keys.c
>> +++ b/tools/testing/selftests/vm/protection_keys.c
>> @@ -461,7 +461,7 @@ void pkey_disable_clear(int pkey, int flags)
>>  			pkey, pkey, pkey_rights);
>>  	pkey_assert(pkey_rights >= 0);
>>
>> -	pkey_rights |= flags;
>> +	pkey_rights &= ~flags;
>>
>>  	ret = pkey_set(pkey, pkey_rights, 0);
>>  	/* pkey_reg and flags have the same format */
>> @@ -475,7 +475,7 @@ void pkey_disable_clear(int pkey, int flags)
>>  	dprintf1("%s(%d) pkey_reg: 0x%016lx\n", __func__,
>>  			pkey, rdpkey_reg());
>>  	if (flags)
>> -		assert(rdpkey_reg() > orig_pkey_reg);
>> +		assert(rdpkey_reg() < orig_pkey_reg);
>>  }
>>
>>  void pkey_write_allow(int pkey)
>
> This seems so horribly wrong that I wonder how it worked in the first
> place.  Any idea?

The code simply wasn't used. pkey_disable_clear() is called by
pkey_write_allow() and pkey_access_allow(), but before this patch series
nothing called either of these functions.


--
Thiago Jung Bauermann
IBM Linux Technology Center
