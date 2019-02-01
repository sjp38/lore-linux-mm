Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC8FBC282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 18:46:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 735A3218A6
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 18:46:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="XcTIasws"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 735A3218A6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C14D78E0002; Fri,  1 Feb 2019 13:46:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC37C8E0001; Fri,  1 Feb 2019 13:46:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A64B58E0002; Fri,  1 Feb 2019 13:46:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7616D8E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 13:46:43 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id w15so9080554qtk.19
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 10:46:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :openpgp:autocrypt:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=H6V3ckqVzfeesnuiqMfK7OvhP+9nOxVDpSZgBdJR6bw=;
        b=BW3JNE20LnTD5g1BH4TshXgkMKutRYX4UUkGqJ8Y4SnCbJZCvc1HK+tdz8UpJaHpmh
         zJ7duUxai9SYhVK77uFEBS0oYAgu02Zyb6sD2dGn13I89maba5bfA66a35ZBf0yXas7M
         /glNgjQdlkPqTF+VH5tmIcmcAMXobi8pAIIvYmHr3xUXwsMZjGM0hsouXYf6KoaeVvPp
         /ckCHH/mlbArTqN1II9IWTjK7LHYfa64w2gqggYrv217volWa99RuoWu3Xoz+NpL7aS4
         njSy4x2KuC/98RZL07V6TmjpyAvW1t8sCGSooIPR2DxsRe5tu7TVHd28AjKO6D/v2QqL
         463A==
X-Gm-Message-State: AJcUukcTdDkf6bygyh5ExnPH4sgkB2yC8fKH11g8bOt11shuuJ4eI+GH
	3GmpQrXZhlWleVISjW3vFZ2DIdn39CxLa5AT05HdlLVoxRHxOOqC2dtsFAA7ninWXoISACYx+vJ
	QPSXn9RBwvVr5M7C87fCXujF0lKy1ycIP3QfshiXp5by8PYCtp/X3qRlCnvla1qzJoQ==
X-Received: by 2002:a37:9bc3:: with SMTP id d186mr36350984qke.22.1549046803171;
        Fri, 01 Feb 2019 10:46:43 -0800 (PST)
X-Google-Smtp-Source: ALg8bN603Cuc35lVfMC2Z4bREsJ00HrVNDutAZQ6dJjX/K5AI9Nq+aGUmxOCt7hApDt1H88MX655
X-Received: by 2002:a37:9bc3:: with SMTP id d186mr36350950qke.22.1549046802249;
        Fri, 01 Feb 2019 10:46:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549046802; cv=none;
        d=google.com; s=arc-20160816;
        b=Guzi9N9gKiz7Bg/RAySqCbB2p+81xJJWO5QAnvBY6nDQGzSn1T9TD/jqiAI3AASY8e
         bgPEhfN1xC6boVGMMIHihRY4fywF6g2IUsdCTUMEYBe6Y2QS9XuvaYsXpnl/czF8LFIM
         55jVXUgHuK0pGZnAWaqu1pDua0l01FNAtpQpRg8gU5ZKpR/dinoa7GFWQxia9w+5CS7O
         QrXqcS51GR1aPbdCRmKZPL98k1pJVDIkwZcpKKvXn6VtZJuVbzBLD1rKThZKF/nzVVjh
         ANZ2z2x6zVXs7wEfERY9gNogPVqdvSPSjb5KJ67X+n/Beww+yc4kqIdcWp/UH3/liACn
         9MSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject:dkim-signature;
        bh=H6V3ckqVzfeesnuiqMfK7OvhP+9nOxVDpSZgBdJR6bw=;
        b=lGLCdDtQDOEOpRmci1ohdwi/WJywqmaXPQ4bF2HQeFd4ZPzJ0DRf69brJ+Rv01GUdt
         qW30br1/y577mQZWtXvsk7LCowTLG9e7to7c3/QUPFM4r+VlbuodmQB26Pe/uNN9ogc0
         NiwwfS78uHNzBorrNO6GvTzyazCdO7VlljrHrEyrHOhFgXg3V2e2pq85bOt4wLoKQPX0
         ltRTq2AxKDA+uO4r4UK2cxi9W/8yMSMc7MRve+wPWEBKPbMKLrx3+aNXsRVE0/LN/Nvr
         RBBsqgYa8yuCwNmwkGUgiICL3naFiqSEUl6erOgFbffg82ZpJG7d+VjlUoWpqT2cWA8g
         qKvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=XcTIasws;
       spf=pass (google.com: domain of boris.ostrovsky@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=boris.ostrovsky@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id p65si261889qkf.138.2019.02.01.10.46.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 10:46:42 -0800 (PST)
Received-SPF: pass (google.com: domain of boris.ostrovsky@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=XcTIasws;
       spf=pass (google.com: domain of boris.ostrovsky@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=boris.ostrovsky@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x11IhxBI179478;
	Fri, 1 Feb 2019 18:46:35 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=H6V3ckqVzfeesnuiqMfK7OvhP+9nOxVDpSZgBdJR6bw=;
 b=XcTIaswsnMz7h71j3UdZp7C4c91vXr6tXhVRDfKmo3uyrH7AbdZnLh2PZf1u/LG9qXP4
 gpK86mwJZf4IImZIrID8sJaG2uWsfI8BQvO9NAW3IUC7ZEQcsyO6SsFQgcj7cFv+HV3F
 Ga9kYrxphzyFCfRbXYfHDHb8vo7NoDP5KN5oF5z2pOJcpHcQVTViKJs2IzltVu1EW3dk
 gRNo2N2K1zAWAPt63rX4Kt2wDeeCh5NCC16lGXYNKT+phpcYZ0XHo6G2bpv1+gLze4u9
 6hWgMcPD/EdINLHebc0pnEWqt8x1w7IpF9w2kZDAtjzXpxBuQdjZX3UxWWt4b2a/wdKD aw== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2120.oracle.com with ESMTP id 2q8g6rr7hk-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 01 Feb 2019 18:46:35 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x11IkYO7006792
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 1 Feb 2019 18:46:34 GMT
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x11IkXoA017780;
	Fri, 1 Feb 2019 18:46:33 GMT
Received: from dhcp-burlington7-2nd-B-east-10-152-55-162.usdhcp.oraclecorp.com (/10.152.32.65)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 01 Feb 2019 10:46:32 -0800
Subject: Re: [PATCH v2 2/2] x86/xen: dont add memory above max allowed
 allocation
To: Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org,
        xen-devel@lists.xenproject.org, x86@kernel.org, linux-mm@kvack.org
Cc: sstabellini@kernel.org, hpa@zytor.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de
References: <20190130082233.23840-1-jgross@suse.com>
 <20190130082233.23840-3-jgross@suse.com>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Openpgp: preference=signencrypt
Autocrypt: addr=boris.ostrovsky@oracle.com; prefer-encrypt=mutual; keydata=
 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
 Jg6OxFYd01z+a+oL
Message-ID: <8d4f7604-cc47-9cd7-2cca-b00b3667d2fa@oracle.com>
Date: Fri, 1 Feb 2019 13:46:18 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
In-Reply-To: <20190130082233.23840-3-jgross@suse.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9154 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902010138
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/30/19 3:22 AM, Juergen Gross wrote:
> Don't allow memory to be added above the allowed maximum allocation
> limit set by Xen.
>
> Trying to do so would result in cases like the following:
>
> [  584.559652] ------------[ cut here ]------------
> [  584.564897] WARNING: CPU: 2 PID: 1 at ../arch/x86/xen/multicalls.c:129 xen_alloc_pte+0x1c7/0x390()
> [  584.575151] Modules linked in:
> [  584.578643] Supported: Yes
> [  584.581750] CPU: 2 PID: 1 Comm: swapper/0 Not tainted 4.4.120-92.70-default #1
> [  584.590000] Hardware name: Cisco Systems Inc UCSC-C460-M4/UCSC-C460-M4, BIOS C460M4.4.0.1b.0.0629181419 06/29/2018
> [  584.601862]  0000000000000000 ffffffff813175a0 0000000000000000 ffffffff8184777c
> [  584.610200]  ffffffff8107f4e1 ffff880487eb7000 ffff8801862b79c0 ffff88048608d290
> [  584.618537]  0000000000487eb7 ffffea0000000201 ffffffff81009de7 ffffffff81068561
> [  584.626876] Call Trace:
> [  584.629699]  [<ffffffff81019ad9>] dump_trace+0x59/0x340
> [  584.635645]  [<ffffffff81019eaa>] show_stack_log_lvl+0xea/0x170
> [  584.642391]  [<ffffffff8101ac51>] show_stack+0x21/0x40
> [  584.648238]  [<ffffffff813175a0>] dump_stack+0x5c/0x7c
> [  584.654085]  [<ffffffff8107f4e1>] warn_slowpath_common+0x81/0xb0
> [  584.660932]  [<ffffffff81009de7>] xen_alloc_pte+0x1c7/0x390
> [  584.667289]  [<ffffffff810647f0>] pmd_populate_kernel.constprop.6+0x40/0x80
> [  584.675241]  [<ffffffff815ecfe8>] phys_pmd_init+0x210/0x255
> [  584.681587]  [<ffffffff815ed207>] phys_pud_init+0x1da/0x247
> [  584.687931]  [<ffffffff815edb3b>] kernel_physical_mapping_init+0xf5/0x1d4
> [  584.695682]  [<ffffffff815e9bdd>] init_memory_mapping+0x18d/0x380
> [  584.702631]  [<ffffffff81064699>] arch_add_memory+0x59/0xf0
>
> Signed-off-by: Juergen Gross <jgross@suse.com>
> ---
>  arch/x86/xen/setup.c      | 10 ++++++++++
>  drivers/xen/xen-balloon.c |  6 ++++++
>  2 files changed, 16 insertions(+)
>
> diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
> index d5f303c0e656..fdb184cadaf5 100644
> --- a/arch/x86/xen/setup.c
> +++ b/arch/x86/xen/setup.c
> @@ -12,6 +12,7 @@
>  #include <linux/memblock.h>
>  #include <linux/cpuidle.h>
>  #include <linux/cpufreq.h>
> +#include <linux/memory_hotplug.h>
>  
>  #include <asm/elf.h>
>  #include <asm/vdso.h>
> @@ -825,6 +826,15 @@ char * __init xen_memory_setup(void)
>  				xen_max_p2m_pfn = pfn_s + n_pfns;
>  			} else
>  				discard = true;
> +#ifdef CONFIG_MEMORY_HOTPLUG
> +			/*
> +			 * Don't allow adding memory not in E820 map while
> +			 * booting the system. Once the balloon driver is up
> +			 * it will remove that restriction again.
> +			 */
> +			max_mem_size = xen_e820_table.entries[i].addr +
> +				       xen_e820_table.entries[i].size;
> +#endif
>  		}
>  
>  		if (!discard)
> diff --git a/drivers/xen/xen-balloon.c b/drivers/xen/xen-balloon.c
> index 2acbfe104e46..2a960fcc812e 100644
> --- a/drivers/xen/xen-balloon.c
> +++ b/drivers/xen/xen-balloon.c
> @@ -37,6 +37,7 @@
>  #include <linux/mm_types.h>
>  #include <linux/init.h>
>  #include <linux/capability.h>
> +#include <linux/memory_hotplug.h>
>  
>  #include <xen/xen.h>
>  #include <xen/interface/xen.h>
> @@ -63,6 +64,11 @@ static void watch_target(struct xenbus_watch *watch,
>  	static bool watch_fired;
>  	static long target_diff;
>  
> +#ifdef CONFIG_MEMORY_HOTPLUG
> +	/* The balloon driver will take care of adding memory now. */
> +	max_mem_size = U64_MAX;
> +#endif


I don't think I understand this. Are you saying the guest should ignore
'mem' boot option?

-boris


> +
>  	err = xenbus_scanf(XBT_NIL, "memory", "target", "%llu", &new_target);
>  	if (err != 1) {
>  		/* This is ok (for domain0 at least) - so just return */

