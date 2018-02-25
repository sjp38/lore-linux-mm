Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id F40376B0003
	for <linux-mm@kvack.org>; Sun, 25 Feb 2018 06:57:30 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id d1so602199qtn.12
        for <linux-mm@kvack.org>; Sun, 25 Feb 2018 03:57:30 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f62si5843297qkd.90.2018.02.25.03.57.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Feb 2018 03:57:29 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1PBsTlc088147
	for <linux-mm@kvack.org>; Sun, 25 Feb 2018 06:57:28 -0500
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gbpfc0pk7-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 25 Feb 2018 06:57:28 -0500
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 25 Feb 2018 04:57:27 -0700
Subject: Re: [PATCH v12 1/3] mm, powerpc, x86: define VM_PKEY_BITx bits if
 CONFIG_ARCH_HAS_PKEYS is enabled
References: <1519257138-23797-2-git-send-email-linuxram@us.ibm.com>
 <201802231528.snWZIspR%fengguang.wu@intel.com>
 <20180224010511.GK5559@ram.oc3035372033.ibm.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Date: Sun, 25 Feb 2018 17:27:11 +0530
MIME-Version: 1.0
In-Reply-To: <20180224010511.GK5559@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <43082fe4-a6e4-2468-0069-4fbc53418c79@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com



On 02/24/2018 06:35 AM, Ram Pai wrote:
> On Fri, Feb 23, 2018 at 03:11:45PM +0800, kbuild test robot wrote:
>> Hi Ram,
>>
>> Thank you for the patch! Yet something to improve:
>>
>> [auto build test ERROR on linus/master]
>> [also build test ERROR on v4.16-rc2 next-20180222]
>> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>>
>>          chmod +x ~/bin/make.cross
> ...snip..
>>          # save the attached .config to linux build tree
>>          make.cross ARCH=powerpc
>>
>> Note: the linux-review/Ram-Pai/mm-x86-powerpc-Enhancements-to-Memory-Protection-Keys/20180223-042743 HEAD c5692bca45543c242ffca15c811923e4c548ed19 builds fine.
>>        It only hurts bisectibility.
> 
> oops, it broke git-bisect on powerpc :-(
> The following change will fix it. This should nail it down.
> 
> diff --git a/arch/powerpc/include/asm/pkeys.h
> b/arch/powerpc/include/asm/pkeys.h
> index 0409c80..0b3b669 100644
> --- a/arch/powerpc/include/asm/pkeys.h
> +++ b/arch/powerpc/include/asm/pkeys.h
> @@ -25,6 +25,7 @@
>   # define VM_PKEY_BIT1  VM_HIGH_ARCH_1
>   # define VM_PKEY_BIT2  VM_HIGH_ARCH_2
>   # define VM_PKEY_BIT3  VM_HIGH_ARCH_3
>   # define VM_PKEY_BIT4  VM_HIGH_ARCH_4
> +#elif !defined(VM_PKEY_BIT4)
> +# define VM_PKEY_BIT4  VM_HIGH_ARCH_4
> #endif
> 

Why don't you remove this powerpc definition completely in this patch? 
Also move that comment above #define. The comments are not specific to
BIT1

@@ -231,9 +231,10 @@ extern int overcommit_kbytes_handler(struct 
ctl_table *, int, void __user *,
  #ifdef CONFIG_ARCH_HAS_PKEYS
  # define VM_PKEY_SHIFT	VM_HIGH_ARCH_BIT_0
  # define VM_PKEY_BIT0	VM_HIGH_ARCH_0	/* A protection key is a 4-bit 
value */
-# define VM_PKEY_BIT1	VM_HIGH_ARCH_1
+# define VM_PKEY_BIT1	VM_HIGH_ARCH_1	/* on x86 and 5-bit value on ppc64 
   */
  # define VM_PKEY_BIT2	VM_HIGH_ARCH_2
  # define VM_PKEY_BIT3	VM_HIGH_ARCH_3
+# define VM_PKEY_BIT4	VM_HIGH_ARCH_4
  #endif /* CONFIG_ARCH_HAS_PKEYS */



-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
