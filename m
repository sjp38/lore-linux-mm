Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B46DE6B04BA
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 14:16:14 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 92so47756651wra.11
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 11:16:14 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k63si974141wmf.26.2017.07.31.11.16.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 11:16:12 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6VIDwWw108319
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 14:16:11 -0400
Received: from e24smtp02.br.ibm.com (e24smtp02.br.ibm.com [32.104.18.86])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2c2511q64s-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 14:16:11 -0400
Received: from localhost
	by e24smtp02.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bauerman@linux.vnet.ibm.com>;
	Mon, 31 Jul 2017 15:16:09 -0300
Received: from d24av03.br.ibm.com (d24av03.br.ibm.com [9.8.31.95])
	by d24relay04.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6VIG5F518415744
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 15:16:05 -0300
Received: from d24av03.br.ibm.com (localhost [127.0.0.1])
	by d24av03.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6VIG8ai016514
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 15:16:08 -0300
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com> <1500177424-13695-14-git-send-email-linuxram@us.ibm.com>
From: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Subject: Re: [RFC v6 13/62] powerpc: track allocation status of all pkeys
In-reply-to: <1500177424-13695-14-git-send-email-linuxram@us.ibm.com>
Date: Mon, 31 Jul 2017 15:15:55 -0300
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87d18g5v6s.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, arnd@arndb.de, corbet@lwn.net, mhocko@kernel.org, dave.hansen@intel.com, mingo@redhat.com, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com


Ram Pai <linuxram@us.ibm.com> writes:
>  static inline int mm_pkey_free(struct mm_struct *mm, int pkey)
>  {
> -	return -EINVAL;
> +	if (!pkey_inited)
> +		return -1;

Sorry, I missed this earlier but the pkey_free syscall will pass this
value to userspace so it needs to be an errno as well (-EINVAL?).

> +
> +	if (!mm_pkey_is_allocated(mm, pkey))
> +		return -EINVAL;
> +
> +	mm_set_pkey_free(mm, pkey);
> +
> +	return 0;
>  }

-- 
Thiago Jung Bauermann
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
