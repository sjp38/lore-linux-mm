Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 903FD6B0005
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 04:05:35 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id m15so1579286qke.16
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 01:05:35 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u82si1697251qka.484.2018.03.14.01.05.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 01:05:34 -0700 (PDT)
Subject: Re: [PATCH] x86, powerpc : pkey-mprotect must allow pkey-0
From: Florian Weimer <fweimer@redhat.com>
References: <1520583161-11741-1-git-send-email-linuxram@us.ibm.com>
 <ec90ed75-2810-bcc3-8439-8dc85a6b46ac@redhat.com>
 <20180309200017.GR1060@ram.oc3035372033.ibm.com>
 <f71b583f-2b66-e9ed-b08b-fddff228a5a7@redhat.com>
Message-ID: <0a6981b3-dcd2-4dce-3209-7f8055d8548f@redhat.com>
Date: Wed, 14 Mar 2018 09:05:30 +0100
MIME-Version: 1.0
In-Reply-To: <f71b583f-2b66-e9ed-b08b-fddff228a5a7@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de, msuchanek@suse.com, Ulrich.Weigand@de.ibm.com

On 03/14/2018 09:00 AM, Florian Weimer wrote:
> On 03/09/2018 09:00 PM, Ram Pai wrote:
>> On Fri, Mar 09, 2018 at 12:04:49PM +0100, Florian Weimer wrote:
>>> On 03/09/2018 09:12 AM, Ram Pai wrote:
>>>> Once an address range is associated with an allocated pkey, it 
>>>> cannot be
>>>> reverted back to key-0. There is no valid reason for the above 
>>>> behavior.
>>>
>>> mprotect without a key does not necessarily use key 0, e.g. if
>>> protection keys are used to emulate page protection flag combination
>>> which is not directly supported by the hardware.
>>>
>>> Therefore, it seems to me that filtering out non-allocated keys is
>>> the right thing to do.
>>
>> I am not sure, what you mean. Do you agree with the patch or otherwise?
> 
> I think it's inconsistent to make key 0 allocated, but not the key which 
> is used for PROT_EXEC emulation, which is still reserved.A  Even if you 
> change the key 0 behavior, it is still not possible to emulate mprotect 
> behavior faithfully with an allocated key.

Ugh.  Should have read the code first before replying:

         /* Do we need to assign a pkey for mm's execute-only maps? */
         if (execute_only_pkey == -1) {
                 /* Go allocate one to use, which might fail */
                 execute_only_pkey = mm_pkey_alloc(mm);
                 if (execute_only_pkey < 0)
                         return -1;
                 need_to_set_mm_pkey = true;
         }

So we do allocate the PROT_EXEC-only key, and I assume it means that the 
key can be restored using pkey_mprotect.  So the key 0 behavior is a 
true exception after all, and it makes sense to realign the behavior 
with the other keys.

Thanks,
Florian
