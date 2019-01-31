Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C072C282D9
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 07:15:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E65F7218AC
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 07:15:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E65F7218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 707A88E0002; Thu, 31 Jan 2019 02:15:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B53F8E0001; Thu, 31 Jan 2019 02:15:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 555A98E0002; Thu, 31 Jan 2019 02:15:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 259DE8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 02:15:23 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id u20so2602738qtk.6
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 23:15:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent:message-id;
        bh=I3WNgtJRhhC3HVr5gIAj+S5a7f7BifDGVvY8/G11H0U=;
        b=SkeHvj9tsc7Ju+C0J5mXJ9VtJumNbSbKtn81QPGfitc6CHemQTOTmOo+srYaLaLxwZ
         zNsr2xWjiumj1LVdz+zRHw3XR8+SLjKfMh7MWkBwcViuu1RP7WVlqMNdRD6gZy3cfbvS
         4K9N2MlX5kjTVpPIYUCTliH3pJdWSDiYzCEM7d5ASE4zVWoKZurFLimTGvvJ8lQMFqkF
         XqxM9hdqZXmW1m2WSPZoV+QsimWNJsRLAUbx+3xSe6LPWInSm9ITq00iu7VpMKRdAPTV
         9drJiq3SII1sXyYe0tcC1Hj8WyMq3upuPWiir1l29zQhHFS1ObojomeXCOa7lkznjqrY
         oarQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUuke3ooj0NUvj4GDMFpRM9KMhzpAQrhLsO/0VG3wydvSYSoatKUdj
	iuN4UArj1sVOe/nJ/o6OwUM0lQg3dbEgdmwlEOQ/IE+695jG8cLIiYujE0XcHPcDXKNjNw82EW8
	TbBAUM9HiQE6GARQRxH21LGeJmqHuVUxydQLJUFtHDdPtyJptY3Cg2bjXWewWM8+43A==
X-Received: by 2002:a0c:baa8:: with SMTP id x40mr31787111qvf.18.1548918922881;
        Wed, 30 Jan 2019 23:15:22 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5LvctxZryNN+dCUP+cP01lFZ1mtCNsiYoqGHopPdGsjZLRhk+/kfWpt7MNxP7nDNeQ91W9
X-Received: by 2002:a0c:baa8:: with SMTP id x40mr31787089qvf.18.1548918922242;
        Wed, 30 Jan 2019 23:15:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548918922; cv=none;
        d=google.com; s=arc-20160816;
        b=yFzn2RAL/dtAd8uDtEyRl8qcvQRLKqbZkDPdsR93WasJUQRy1UF86C8jfkPHKnMlyJ
         yGvCSHI1e3/G42F1tZxags80qhs13HXbmW6NybvqgoEVOvCHDhyGY3e4O0cq5iNJPoQT
         R74y/7vWExgTyEAn1b85IUj13wveYzKBq/RvC8F0Wt+OA1z1IWxuGCCKhTW4OCdqSx5b
         EnF2JdzSB/MgppPGXfblCK1TKTn7beDXDx93/l9HWI3J4HuyMzj0l3XopfkdkWFB7TDu
         8Nea/oqLdDyklmhfw4nG2irvftHVC6nmLLg32tByg5JL24jLN7pIV+Bs/xkKGpxqSHPf
         mong==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:subject:cc:to:from:date;
        bh=I3WNgtJRhhC3HVr5gIAj+S5a7f7BifDGVvY8/G11H0U=;
        b=xE320PfLvIz548H7MEbOnfe6hQIwCnIDvyA6n7YecxQG3V7KYy7NUgv9wOp56j2HWi
         4C6733JxQyNsyImofz8WxZLPo+WGGy+k3wja+dabnTWR2qb6okPwSFhC6SNbuZhAgpL1
         mM18IIZjV4DhFDd/8h0QNNbns2BLm/PBF4ghfqSAfFR6WN4isLAwZUFuK95MLk5M5MHR
         PcrqvsRezTLLrM8GoxeZpZuQIUlKphJRHlAzoAusGD+UjJqEMqZqq2TndWxNLorDKXMu
         CG5MrOKJ2nEsmD0oeuhKeo3WnYdWGGdWkl/ZFjhJXdTeL3I0GklnvyuxXt9yWlqDSmVc
         /HrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f57si184151qtf.362.2019.01.30.23.15.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 23:15:22 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0V7ExNI062151
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 02:15:21 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qbtbkn9pw-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 02:15:21 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 31 Jan 2019 07:15:17 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 31 Jan 2019 07:15:07 -0000
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0V7F6tN55378120
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 31 Jan 2019 07:15:06 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D50C74C046;
	Thu, 31 Jan 2019 07:15:04 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5E7D14C040;
	Thu, 31 Jan 2019 07:15:01 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 31 Jan 2019 07:15:01 +0000 (GMT)
Date: Thu, 31 Jan 2019 09:14:59 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: linux-mm@kvack.org, Rich Felker <dalias@libc.org>,
        linux-ia64@vger.kernel.org, devicetree@vger.kernel.org,
        Catalin Marinas <catalin.marinas@arm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>, x86@kernel.org,
        linux-mips@vger.kernel.org, Max Filippov <jcmvbkbc@gmail.com>,
        Guo Ren <guoren@kernel.org>, sparclinux@vger.kernel.org,
        Christoph Hellwig <hch@lst.de>, linux-s390@vger.kernel.org,
        linux-c6x-dev@linux-c6x.org,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Richard Weinberger <richard@nod.at>, linux-sh@vger.kernel.org,
        Russell King <linux@armlinux.org.uk>, kasan-dev@googlegroups.com,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Mark Salter <msalter@redhat.com>, Dennis Zhou <dennis@kernel.org>,
        Matt Turner <mattst88@gmail.com>, linux-snps-arc@lists.infradead.org,
        uclinux-h8-devel@lists.sourceforge.jp, Petr Mladek <pmladek@suse.com>,
        linux-xtensa@linux-xtensa.org, linux-alpha@vger.kernel.org,
        linux-um@lists.infradead.org, linux-m68k@lists.linux-m68k.org,
        Rob Herring <robh+dt@kernel.org>, Greentime Hu <green.hu@gmail.com>,
        xen-devel@lists.xenproject.org, Stafford Horne <shorne@gmail.com>,
        Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org,
        Michal Simek <monstr@monstr.eu>, Tony Luck <tony.luck@intel.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
        Paul Burton <paul.burton@mips.com>, Vineet Gupta <vgupta@synopsys.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>,
        openrisc@lists.librecores.org, Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH v2 19/21] treewide: add checks for the return value of
 memblock_alloc*()
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
 <1548057848-15136-20-git-send-email-rppt@linux.ibm.com>
 <b7c12014-14ae-2a38-900c-41fd145307bc@c-s.fr>
 <20190131064139.GB28876@rapoport-lnx>
 <8838f7ab-998b-6d78-02a8-a53f8a3619d9@c-s.fr>
 <d5e4ff5b-d33a-e641-8159-d4f83bc28d0b@c-s.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <d5e4ff5b-d33a-e641-8159-d4f83bc28d0b@c-s.fr>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19013107-0020-0000-0000-0000030F29F7
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19013107-0021-0000-0000-000021602B4F
Message-Id: <20190131071459.GC28876@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-31_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901310057
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 08:07:29AM +0100, Christophe Leroy wrote:
> 
> 
> Le 31/01/2019 à 07:44, Christophe Leroy a écrit :
> >
> >
> >Le 31/01/2019 à 07:41, Mike Rapoport a écrit :
> >>On Thu, Jan 31, 2019 at 07:07:46AM +0100, Christophe Leroy wrote:
> >>>
> >>>
> >>>Le 21/01/2019 à 09:04, Mike Rapoport a écrit :
> >>>>Add check for the return value of memblock_alloc*() functions and call
> >>>>panic() in case of error.
> >>>>The panic message repeats the one used by panicing memblock
> >>>>allocators with
> >>>>adjustment of parameters to include only relevant ones.
> >>>>
> >>>>The replacement was mostly automated with semantic patches like the one
> >>>>below with manual massaging of format strings.
> >>>>
> >>>>@@
> >>>>expression ptr, size, align;
> >>>>@@
> >>>>ptr = memblock_alloc(size, align);
> >>>>+ if (!ptr)
> >>>>+     panic("%s: Failed to allocate %lu bytes align=0x%lx\n", __func__,
> >>>>size, align);
> >>>>
> >>>>Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> >>>>Reviewed-by: Guo Ren <ren_guo@c-sky.com>             # c-sky
> >>>>Acked-by: Paul Burton <paul.burton@mips.com>         # MIPS
> >>>>Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com> # s390
> >>>>Reviewed-by: Juergen Gross <jgross@suse.com>         # Xen
> >>>>---
> >>>
> >>>[...]
> >>>
> >>>>diff --git a/mm/sparse.c b/mm/sparse.c
> >>>>index 7ea5dc6..ad94242 100644
> >>>>--- a/mm/sparse.c
> >>>>+++ b/mm/sparse.c
> >>>
> >>>[...]
> >>>
> >>>>@@ -425,6 +436,10 @@ static void __init sparse_buffer_init(unsigned
> >>>>long size, int nid)
> >>>>          memblock_alloc_try_nid_raw(size, PAGE_SIZE,
> >>>>                          __pa(MAX_DMA_ADDRESS),
> >>>>                          MEMBLOCK_ALLOC_ACCESSIBLE, nid);
> >>>>+    if (!sparsemap_buf)
> >>>>+        panic("%s: Failed to allocate %lu bytes align=0x%lx nid=%d
> >>>>from=%lx\n",
> >>>>+              __func__, size, PAGE_SIZE, nid, __pa(MAX_DMA_ADDRESS));
> >>>>+
> >>>
> >>>memblock_alloc_try_nid_raw() does not panic (help explicitly says:
> >>>Does not
> >>>zero allocated memory, does not panic if request cannot be satisfied.).
> >>
> >>"Does not panic" does not mean it always succeeds.
> >
> >I agree, but at least here you are changing the behaviour by making it
> >panic explicitly. Are we sure there are not cases where the system could
> >just continue functionning ? Maybe a WARN_ON() would be enough there ?
> 
> Looking more in details, it looks like everything is done to live with
> sparsemap_buf NULL, all functions using it check it so having it NULL
> shouldn't imply a panic I believe, see code below.

You are right, I'm preparing the fix right now.
 
> static void *sparsemap_buf __meminitdata;
> static void *sparsemap_buf_end __meminitdata;
> 
> static void __init sparse_buffer_init(unsigned long size, int nid)
> {
> 	WARN_ON(sparsemap_buf);	/* forgot to call sparse_buffer_fini()? */
> 	sparsemap_buf =
> 		memblock_alloc_try_nid_raw(size, PAGE_SIZE,
> 						__pa(MAX_DMA_ADDRESS),
> 						MEMBLOCK_ALLOC_ACCESSIBLE, nid);
> 	sparsemap_buf_end = sparsemap_buf + size;
> }
> 
> static void __init sparse_buffer_fini(void)
> {
> 	unsigned long size = sparsemap_buf_end - sparsemap_buf;
> 
> 	if (sparsemap_buf && size > 0)
> 		memblock_free_early(__pa(sparsemap_buf), size);
> 	sparsemap_buf = NULL;
> }
> 
> void * __meminit sparse_buffer_alloc(unsigned long size)
> {
> 	void *ptr = NULL;
> 
> 	if (sparsemap_buf) {
> 		ptr = PTR_ALIGN(sparsemap_buf, size);
> 		if (ptr + size > sparsemap_buf_end)
> 			ptr = NULL;
> 		else
> 			sparsemap_buf = ptr + size;
> 	}
> 	return ptr;
> }
> 
> 
> Christophe
> 

-- 
Sincerely yours,
Mike.

