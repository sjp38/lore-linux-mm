Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id AE0DE6B02F4
	for <linux-mm@kvack.org>; Sun,  9 Jul 2017 23:07:23 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v88so21250826wrb.1
        for <linux-mm@kvack.org>; Sun, 09 Jul 2017 20:07:23 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l133si5494375wmg.133.2017.07.09.20.07.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jul 2017 20:07:22 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6A33YoP040489
	for <linux-mm@kvack.org>; Sun, 9 Jul 2017 23:07:21 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2bjsyjnj19-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 09 Jul 2017 23:07:20 -0400
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 10 Jul 2017 13:07:16 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6A37Dkx18087966
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 13:07:13 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6A373QS003769
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 13:07:04 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: Re: [RFC v5 38/38] Documentation: PowerPC specific updates to memory
 protection keys
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
 <1499289735-14220-39-git-send-email-linuxram@us.ibm.com>
Date: Mon, 10 Jul 2017 08:37:04 +0530
MIME-Version: 1.0
In-Reply-To: <1499289735-14220-39-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <d94ab2c1-8be5-f618-6f42-cac2813059a5@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On 07/06/2017 02:52 AM, Ram Pai wrote:
> Add documentation updates that capture PowerPC specific changes.
> 
> Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> ---
>  Documentation/vm/protection-keys.txt |   85 ++++++++++++++++++++++++++--------
>  1 files changed, 65 insertions(+), 20 deletions(-)
> 
> diff --git a/Documentation/vm/protection-keys.txt b/Documentation/vm/protection-keys.txt
> index b643045..d50b6ab 100644
> --- a/Documentation/vm/protection-keys.txt
> +++ b/Documentation/vm/protection-keys.txt
> @@ -1,21 +1,46 @@
> -Memory Protection Keys for Userspace (PKU aka PKEYs) is a CPU feature
> -which will be found on future Intel CPUs.
> +Memory Protection Keys for Userspace (PKU aka PKEYs) is a CPU feature found in
> +new generation of intel CPUs and on PowerPC 7 and higher CPUs.
>  
>  Memory Protection Keys provides a mechanism for enforcing page-based
> -protections, but without requiring modification of the page tables
> -when an application changes protection domains.  It works by
> -dedicating 4 previously ignored bits in each page table entry to a
> -"protection key", giving 16 possible keys.
> -
> -There is also a new user-accessible register (PKRU) with two separate
> -bits (Access Disable and Write Disable) for each key.  Being a CPU
> -register, PKRU is inherently thread-local, potentially giving each
> -thread a different set of protections from every other thread.
> -
> -There are two new instructions (RDPKRU/WRPKRU) for reading and writing
> -to the new register.  The feature is only available in 64-bit mode,
> -even though there is theoretically space in the PAE PTEs.  These
> -permissions are enforced on data access only and have no effect on
> +protections, but without requiring modification of the page tables when an
> +application changes protection domains.
> +
> +
> +On Intel:
> +
> +	It works by dedicating 4 previously ignored bits in each page table
> +	entry to a "protection key", giving 16 possible keys.
> +
> +	There is also a new user-accessible register (PKRU) with two separate
> +	bits (Access Disable and Write Disable) for each key.  Being a CPU
> +	register, PKRU is inherently thread-local, potentially giving each
> +	thread a different set of protections from every other thread.
> +
> +	There are two new instructions (RDPKRU/WRPKRU) for reading and writing
> +	to the new register.  The feature is only available in 64-bit mode,
> +	even though there is theoretically space in the PAE PTEs.  These
> +	permissions are enforced on data access only and have no effect on
> +	instruction fetches.
> +
> +
> +On PowerPC:
> +
> +	It works by dedicating 5 page table entry bits to a "protection key",
> +	giving 32 possible keys.
> +
> +	There  is  a  user-accessible  register (AMR)  with  two separate bits;
> +	Access Disable and  Write  Disable, for  each key.  Being  a  CPU
> +	register,  AMR  is inherently  thread-local,  potentially  giving  each
> +	thread a different set of protections from every other thread.  NOTE:
> +	Disabling read permission does not disable write and vice-versa.

We can only enable/disable entire access or write. Then how
read permission can be changed with protection keys directly ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
