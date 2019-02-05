Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 819D2C282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 17:42:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 252752081B
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 17:42:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 252752081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74F128E0094; Tue,  5 Feb 2019 12:42:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D5418E0093; Tue,  5 Feb 2019 12:42:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5774D8E0094; Tue,  5 Feb 2019 12:42:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2932E8E0093
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 12:42:50 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id d35so4243413qtd.20
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 09:42:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=ys9/8iZI2+AZ770JEgmBUcU9oubRnjFWNVLnWXmDC5A=;
        b=Adgh4llsl/Ukx9Cfj40pvrsJqoAsUWmJQNA73Bw5nTYwPt3kOaHIVCq0/TgCph4/bE
         3Orkh44G2gW3wJnMOINTda3E/jFXvNWoRY1vuwOeZDTSudvlK3lL1D4S991WN+m/HE2w
         JedAqug4dAVXEU2Ulea3b2Yu/Bs4wKj/LC8jhwPbees25O3oi8I7j64nf2Ung02JXEvf
         nTxIFJoBxLhXpLsVovkCPPKlxFuoJLvkeKS6AJbYD3kUcvo7joyISxzvHufmR6AF2+hl
         2buAuLQJuvJMWUhyGouIOGgDBpfv0Rxb30P0VjJe79/Q+pJZ1X2p2ZUh/wqtHYwTqRdI
         lzWg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of muriloo@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=muriloo@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuZ2597IRhh2yMgBP1WC7dTANT1q8euMYqpGDJP16zu3MFmendGf
	P/K5NSb0DLVDBdsKdxbiAWY3WbpntRpTRIUAoHQ47co8O0gOWfEkcDCMQBZUfuZBdmq8hd+kgGI
	LZLAxD0swR2R4ZxQbsCSHneT0fRJvBK9TebTe/fK+aQKwe1SeD142GoojlCom7uiLKA==
X-Received: by 2002:ae9:f302:: with SMTP id p2mr4426609qkg.337.1549388569892;
        Tue, 05 Feb 2019 09:42:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZSfcjsYu0bB4UyOVSKnZgpcvvndpPDzO7aCCxPURErPDiD/hZz91dectDpUbvplDMUvrQK
X-Received: by 2002:ae9:f302:: with SMTP id p2mr4426577qkg.337.1549388569189;
        Tue, 05 Feb 2019 09:42:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549388569; cv=none;
        d=google.com; s=arc-20160816;
        b=Jti+XJR+QNF1X5gC9cTFM3ABX99AeGaVj9TuO9Ej+bfh0LzgZjabk+MvhfYfuQb2hF
         yIXjFQvf41PoAiI6rAH/GLTcWWWG87zk7mLj29cIk3O12b0kqo8oEheT/KMLZUadM5Xu
         Gg1N04O4hlcbqNw8bkG2Dvzt4LC82SwKKtj/G/dtHdpoupkWJPsqIt3LGDsPRmilgSvF
         6oFmZpmCLCkJGFF3qGdm72sOEngv/XRhdHFAGJEyIzIWs4kHT5etUApuLBhHliXNhZ/f
         YmGDegjimWKajdhtnQgS52ofXdvXpXVzXIEe/FJqetcWhg7urMQ/u2xc4L3u5O/tQt2R
         1VMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=ys9/8iZI2+AZ770JEgmBUcU9oubRnjFWNVLnWXmDC5A=;
        b=G6Iy/fhJub+i+jcUxTsSQS/wOIk0mbTlDcilZ6sLkuWO4OHlZ9ISSD/rXtd1vLyr13
         msuAaRWI4kYpZUuonveVOfz1hBZXd9kZFNbNp4Son2kKD3CQlFvHdOnfgYOTsbZo4I7u
         kh7Y3nSPPhZsP/WpmvgN158TktHl4GlH5KGWrsD7bdef9wbsmrV9Ek4LDnuVxMNYfR/5
         Qby4DD4A+qahKdc0O0ALvzI1QycjjRzYq4Ud4AaavMjKlv55e/0S+Vqp3mwUNVO0iTeq
         lpwK9Wv1Z6kdyqQ/Fnt5EN9PueRtzSWcvrEsYiD6RhITBONLT+F98wwkz9ucvEWsPR63
         E6RQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of muriloo@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=muriloo@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w3si1154247qtn.134.2019.02.05.09.42.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 09:42:49 -0800 (PST)
Received-SPF: pass (google.com: domain of muriloo@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of muriloo@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=muriloo@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x15Has5G090244
	for <linux-mm@kvack.org>; Tue, 5 Feb 2019 12:42:48 -0500
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qfet3gyxb-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 05 Feb 2019 12:42:48 -0500
Received: from localhost
	by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <muriloo@linux.ibm.com>;
	Tue, 5 Feb 2019 17:42:47 -0000
Received: from b01cxnp22036.gho.pok.ibm.com (9.57.198.26)
	by e11.ny.us.ibm.com (146.89.104.198) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 5 Feb 2019 17:42:45 -0000
Received: from b01ledav006.gho.pok.ibm.com (b01ledav006.gho.pok.ibm.com [9.57.199.111])
	by b01cxnp22036.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x15HgiNh16908464
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 5 Feb 2019 17:42:44 GMT
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 1D718AC05B;
	Tue,  5 Feb 2019 17:42:44 +0000 (GMT)
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D0933AC05F;
	Tue,  5 Feb 2019 17:42:43 +0000 (GMT)
Received: from localhost (unknown [9.18.235.42])
	by b01ledav006.gho.pok.ibm.com (Postfix) with ESMTPS;
	Tue,  5 Feb 2019 17:42:43 +0000 (GMT)
Date: Tue, 5 Feb 2019 15:42:42 -0200
From: Murilo Opsfelder Araujo <muriloo@linux.ibm.com>
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Kees Cook <keescook@chromium.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>,
        Mike Rapoport <rppt@linux.ibm.com>, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3 1/2] mm: add probe_user_read()
References: <39fb6c5a191025378676492e140dc012915ecaeb.1547652372.git.christophe.leroy@c-s.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <39fb6c5a191025378676492e140dc012915ecaeb.1547652372.git.christophe.leroy@c-s.fr>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-TM-AS-GCONF: 00
x-cbid: 19020517-2213-0000-0000-0000034AA0F5
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010542; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000279; SDB=6.01156741; UDB=6.00603425; IPR=6.00937266;
 MB=3.00025447; MTD=3.00000008; XFM=3.00000015; UTC=2019-02-05 17:42:47
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19020517-2214-0000-0000-00005D3E444D
Message-Id: <20190205174242.GA24427@kermit.br.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-05_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902050135
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Christophe.

On Wed, Jan 16, 2019 at 04:59:27PM +0000, Christophe Leroy wrote:
> In powerpc code, there are several places implementing safe
> access to user data. This is sometimes implemented using
> probe_kernel_address() with additional access_ok() verification,
> sometimes with get_user() enclosed in a pagefault_disable()/enable()
> pair, etc. :
>     show_user_instructions()
>     bad_stack_expansion()
>     p9_hmi_special_emu()
>     fsl_pci_mcheck_exception()
>     read_user_stack_64()
>     read_user_stack_32() on PPC64
>     read_user_stack_32() on PPC32
>     power_pmu_bhrb_to()
>
> In the same spirit as probe_kernel_read(), this patch adds
> probe_user_read().
>
> probe_user_read() does the same as probe_kernel_read() but
> first checks that it is really a user address.
>
> The patch defines this function as a static inline so the "size"
> variable can be examined for const-ness by the check_object_size()
> in __copy_from_user_inatomic()
>
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
> ---
>  v3: Moved 'Returns:" comment after description.
>      Explained in the commit log why the function is defined static inline
>
>  v2: Added "Returns:" comment and removed probe_user_address()
>
>  include/linux/uaccess.h | 34 ++++++++++++++++++++++++++++++++++
>  1 file changed, 34 insertions(+)
>
> diff --git a/include/linux/uaccess.h b/include/linux/uaccess.h
> index 37b226e8df13..ef99edd63da3 100644
> --- a/include/linux/uaccess.h
> +++ b/include/linux/uaccess.h
> @@ -263,6 +263,40 @@ extern long strncpy_from_unsafe(char *dst, const void *unsafe_addr, long count);
>  #define probe_kernel_address(addr, retval)		\
>  	probe_kernel_read(&retval, addr, sizeof(retval))
>
> +/**
> + * probe_user_read(): safely attempt to read from a user location
> + * @dst: pointer to the buffer that shall take the data
> + * @src: address to read from
> + * @size: size of the data chunk
> + *
> + * Safely read from address @src to the buffer at @dst.  If a kernel fault
> + * happens, handle that and return -EFAULT.
> + *
> + * We ensure that the copy_from_user is executed in atomic context so that
> + * do_page_fault() doesn't attempt to take mmap_sem.  This makes
> + * probe_user_read() suitable for use within regions where the caller
> + * already holds mmap_sem, or other locks which nest inside mmap_sem.
> + *
> + * Returns: 0 on success, -EFAULT on error.
> + */
> +
> +#ifndef probe_user_read
> +static __always_inline long probe_user_read(void *dst, const void __user *src,
> +					    size_t size)
> +{
> +	long ret;
> +
> +	if (!access_ok(src, size))
> +		return -EFAULT;

Hopefully, there is still time for a minor comment.

Do we need to differentiate the returned error here, e.g.: return
-EACCES?

I wonder if there will be situations where callers need to know why
probe_user_read() failed.

Besides that:

Acked-by: Murilo Opsfelder Araujo <muriloo@linux.ibm.com>

> +
> +	pagefault_disable();
> +	ret = __copy_from_user_inatomic(dst, src, size);
> +	pagefault_enable();
> +
> +	return ret ? -EFAULT : 0;
> +}
> +#endif
> +
>  #ifndef user_access_begin
>  #define user_access_begin(ptr,len) access_ok(ptr, len)
>  #define user_access_end() do { } while (0)
> --
> 2.13.3
>

--
Murilo

