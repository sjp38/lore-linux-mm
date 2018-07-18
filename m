Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5DA9D6B000C
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 11:53:59 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v9-v6so2523519pff.4
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 08:53:59 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id b4-v6si3384946pgc.654.2018.07.18.08.53.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 08:53:58 -0700 (PDT)
Subject: Re: [PATCH v14 11/22] selftests/vm: introduce two arch independent
 abstraction
References: <1531835365-32387-1-git-send-email-linuxram@us.ibm.com>
 <1531835365-32387-12-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <5c557b14-8898-9afc-ba9e-3e5ab2e0aa31@intel.com>
Date: Wed, 18 Jul 2018 08:52:57 -0700
MIME-Version: 1.0
In-Reply-To: <1531835365-32387-12-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

On 07/17/2018 06:49 AM, Ram Pai wrote:
> open_hugepage_file() <- opens the huge page file

Folks, a sentence here would be nice:

	Different architectures have different huge page sizes and thus
	have different sysfs filees to manipulate when allocating huge
	pages.

> get_start_key() <--  provides the first non-reserved key.

Does powerpc not start on key 0?  Why do you need this?

> cc: Dave Hansen <dave.hansen@intel.com>
> cc: Florian Weimer <fweimer@redhat.com>
> Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> Signed-off-by: Thiago Jung Bauermann <bauerman@linux.ibm.com>
> Reviewed-by: Dave Hansen <dave.hansen@intel.com>
> ---
>  tools/testing/selftests/vm/pkey-helpers.h    |   10 ++++++++++
>  tools/testing/selftests/vm/pkey-x86.h        |    1 +
>  tools/testing/selftests/vm/protection_keys.c |    6 +++---
>  3 files changed, 14 insertions(+), 3 deletions(-)
> 
> diff --git a/tools/testing/selftests/vm/pkey-helpers.h b/tools/testing/selftests/vm/pkey-helpers.h
> index ada0146..52a1152 100644
> --- a/tools/testing/selftests/vm/pkey-helpers.h
> +++ b/tools/testing/selftests/vm/pkey-helpers.h
> @@ -179,4 +179,14 @@ static inline void __pkey_write_allow(int pkey, int do_allow_write)
>  #define __stringify_1(x...)     #x
>  #define __stringify(x...)       __stringify_1(x)
>  
> +static inline int open_hugepage_file(int flag)
> +{
> +	return open(HUGEPAGE_FILE, flag);
> +}

open_nr_hugepages_file() if you revise this, please
> +
> +static inline int get_start_key(void)
> +{
> +	return 1;
> +}

get_first_user_pkey(), please.

>  #endif /* _PKEYS_HELPER_H */
> diff --git a/tools/testing/selftests/vm/pkey-x86.h b/tools/testing/selftests/vm/pkey-x86.h
> index 2b3780d..d5fa299 100644
> --- a/tools/testing/selftests/vm/pkey-x86.h
> +++ b/tools/testing/selftests/vm/pkey-x86.h
> @@ -48,6 +48,7 @@
>  #define MB			(1<<20)
>  #define pkey_reg_t		u32
>  #define PKEY_REG_FMT		"%016x"
> +#define HUGEPAGE_FILE		"/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages"
>  
>  static inline u32 pkey_bit_position(int pkey)
>  {
> diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
> index 2565b4c..2e448e0 100644
> --- a/tools/testing/selftests/vm/protection_keys.c
> +++ b/tools/testing/selftests/vm/protection_keys.c
> @@ -788,7 +788,7 @@ void setup_hugetlbfs(void)
>  	 * Now go make sure that we got the pages and that they
>  	 * are 2M pages.  Someone might have made 1G the default.
>  	 */
> -	fd = open("/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages", O_RDONLY);
> +	fd = open_hugepage_file(O_RDONLY);
>  	if (fd < 0) {
>  		perror("opening sysfs 2M hugetlb config");
>  		return;

This is fine, and obviously necessary.

> @@ -1075,10 +1075,10 @@ void test_kernel_gup_write_to_write_disabled_region(int *ptr, u16 pkey)
>  void test_pkey_syscalls_on_non_allocated_pkey(int *ptr, u16 pkey)
>  {
>  	int err;
> -	int i;
> +	int i = get_start_key();
>  
>  	/* Note: 0 is the default pkey, so don't mess with it */
> -	for (i = 1; i < NR_PKEYS; i++) {
> +	for (; i < NR_PKEYS; i++) {
>  		if (pkey == i)
>  			continue;

Grumble, grumble, you moved the code away from the comment connected to
it.
