Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C20326B000A
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 15:39:09 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id e15so2512944wrj.14
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 12:39:09 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o56si1318833edc.525.2018.03.26.12.39.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 12:39:08 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2QJZOUt006147
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 15:39:06 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gy48sfbk2-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 15:39:06 -0400
Received: from localhost
	by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bauerman@linux.vnet.ibm.com>;
	Mon, 26 Mar 2018 15:39:05 -0400
References: <1519264541-7621-1-git-send-email-linuxram@us.ibm.com> <1519264541-7621-5-git-send-email-linuxram@us.ibm.com> <00081300-e891-3381-3acd-e3312e54fb58@intel.com>
From: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Subject: Re: [PATCH v12 04/22] selftests/vm: typecast the pkey register
In-reply-to: <00081300-e891-3381-3acd-e3312e54fb58@intel.com>
Date: Mon, 26 Mar 2018 16:38:51 -0300
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87h8p239v8.fsf@morokweng.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, ebiederm@xmission.com, arnd@arndb.de


Dave Hansen <dave.hansen@intel.com> writes:

> On 02/21/2018 05:55 PM, Ram Pai wrote:
>> -static inline unsigned int _rdpkey_reg(int line)
>> +static inline pkey_reg_t _rdpkey_reg(int line)
>>  {
>> -	unsigned int pkey_reg = __rdpkey_reg();
>> +	pkey_reg_t pkey_reg = __rdpkey_reg();
>>
>> -	dprintf4("rdpkey_reg(line=%d) pkey_reg: %x shadow: %x\n",
>> +	dprintf4("rdpkey_reg(line=%d) pkey_reg: %016lx shadow: %016lx\n",
>>  			line, pkey_reg, shadow_pkey_reg);
>>  	assert(pkey_reg == shadow_pkey_reg);
>
> Hmm.  So we're using %lx for an int?  Doesn't the compiler complain
> about this?

It doesn't because dprintf4() doesn't have the annotation that tells the
compiler that it takes printf-like arguments. Once I add it:

--- a/tools/testing/selftests/vm/pkey-helpers.h
+++ b/tools/testing/selftests/vm/pkey-helpers.h
@@ -54,6 +54,10 @@
 #define DPRINT_IN_SIGNAL_BUF_SIZE 4096
 extern int dprint_in_signal;
 extern char dprint_in_signal_buffer[DPRINT_IN_SIGNAL_BUF_SIZE];
+
+#ifdef __GNUC__
+__attribute__((format(printf, 1, 2)))
+#endif
 static inline void sigsafe_printf(const char *format, ...)
 {
 	va_list ap;

Then it does complain about it. I'm working on a fix where each arch
will define a format string to use for its pkey_reg_t and use it like
this:

--- a/tools/testing/selftests/vm/pkey-helpers.h
+++ b/tools/testing/selftests/vm/pkey-helpers.h
@@ -19,6 +19,7 @@
 #define u32 uint32_t
 #define u64 uint64_t
 #define pkey_reg_t u32
+#define PKEY_REG_FMT "%016x"

 #ifdef __i386__
 #ifndef SYS_mprotect_key
@@ -112,7 +113,8 @@ static inline pkey_reg_t _read_pkey_reg(int line)
 {
 	pkey_reg_t pkey_reg = __read_pkey_reg();

-	dprintf4("read_pkey_reg(line=%d) pkey_reg: %016lx shadow: %016lx\n",
+	dprintf4("read_pkey_reg(line=%d) pkey_reg: "PKEY_REG_FMT
+			" shadow: "PKEY_REG_FMT"\n",
 			line, pkey_reg, shadow_pkey_reg);
 	assert(pkey_reg == shadow_pkey_reg);

--
Thiago Jung Bauermann
IBM Linux Technology Center
