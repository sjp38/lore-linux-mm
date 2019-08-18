Return-Path: <SRS0=q2Op=WO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B9F8C3A59F
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 08:20:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA4CA21773
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 08:20:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA4CA21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6FD3A6B000C; Sun, 18 Aug 2019 04:20:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6ADCC6B000D; Sun, 18 Aug 2019 04:20:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C4E96B000E; Sun, 18 Aug 2019 04:20:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0158.hostedemail.com [216.40.44.158])
	by kanga.kvack.org (Postfix) with ESMTP id 3CA4E6B000C
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 04:20:48 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id E07D48248AC2
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 08:20:47 +0000 (UTC)
X-FDA: 75834852534.04.vase86_411ab8ae28508
X-HE-Tag: vase86_411ab8ae28508
X-Filterd-Recvd-Size: 6846
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 08:20:47 +0000 (UTC)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7I8GVv5130383
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 04:20:45 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2uey3v64dj-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 04:20:45 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 18 Aug 2019 09:20:43 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sun, 18 Aug 2019 09:20:39 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7I8KcEF37879812
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 18 Aug 2019 08:20:38 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B902DA404D;
	Sun, 18 Aug 2019 08:20:38 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A7FDAA4059;
	Sun, 18 Aug 2019 08:20:37 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.59])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Sun, 18 Aug 2019 08:20:37 +0000 (GMT)
Date: Sun, 18 Aug 2019 11:20:35 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: Russell King - ARM Linux admin <linux@armlinux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Zhaoyang Huang <zhaoyang.huang@unisoc.com>,
        Rob Herring <robh@kernel.org>, Florian Fainelli <f.fainelli@gmail.com>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Doug Berger <opendmb@gmail.com>,
        "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] arch : arm : add a criteria for pfn_valid
References: <1566010813-27219-1-git-send-email-huangzhaoyang@gmail.com>
 <20190817183240.GM13294@shell.armlinux.org.uk>
 <CAGWkznEvHE6B+eLnCn=s8Hgm3FFbbXcEdj_OxCM4NOj0u61FGA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGWkznEvHE6B+eLnCn=s8Hgm3FFbbXcEdj_OxCM4NOj0u61FGA@mail.gmail.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19081808-0020-0000-0000-00000360F422
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19081808-0021-0000-0000-000021B61BE5
Message-Id: <20190818082035.GD10627@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-18_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908180092
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 18, 2019 at 03:46:51PM +0800, Zhaoyang Huang wrote:
> On Sun, Aug 18, 2019 at 2:32 AM Russell King - ARM Linux admin
> <linux@armlinux.org.uk> wrote:
> >
> > On Sat, Aug 17, 2019 at 11:00:13AM +0800, Zhaoyang Huang wrote:
> > > From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
> > >
> > > pfn_valid can be wrong while the MSB of physical address be trimed as pfn
> > > larger than the max_pfn.
> >
> > What scenario are you addressing here?  At a guess, you're addressing
> > the non-LPAE case with PFNs that correspond with >= 4GiB of memory?
> Please find bellowing for the callstack caused by this defect. The
> original reason is a invalid PFN passed from userspace which will
> introduce a invalid page within stable_page_flags and then kernel
> panic.

Yeah, arm64 hit this issue a while ago and it was fixed with commit
5ad356eabc47 ("arm64: mm: check for upper PAGE_SHIFT bits in pfn_valid()").

IMHO, the check 

	if ((addr >> PAGE_SHIFT) != pfn)

is more robust than comparing pfn to max_pfn.

 
> [46886.723249] c7 [<c031ff98>] (stable_page_flags) from [<c03203f8>]
> (kpageflags_read+0x90/0x11c)
> [46886.723256] c7  r9:c101ce04 r8:c2d0bf70 r7:c2d0bf70 r6:1fbb10fb
> r5:a8686f08 r4:a8686f08
> [46886.723264] c7 [<c0320368>] (kpageflags_read) from [<c0312030>]
> (proc_reg_read+0x80/0x94)
> [46886.723270] c7  r10:000000b4 r9:00000008 r8:c2d0bf70 r7:00000000
> r6:00000001 r5:ed8e7240
> [46886.723272] c7  r4:00000000
> [46886.723280] c7 [<c0311fb0>] (proc_reg_read) from [<c02a6e6c>]
> (__vfs_read+0x48/0x150)
> [46886.723284] c7  r7:c2d0bf70 r6:c0f09208 r5:c0a4f940 r4:c40326c0
> [46886.723290] c7 [<c02a6e24>] (__vfs_read) from [<c02a7018>]
> (vfs_read+0xa4/0x158)
> [46886.723296] c7  r9:a8686f08 r8:00000008 r7:c2d0bf70 r6:a8686f08
> r5:c40326c0 r4:00000008
> [46886.723301] c7 [<c02a6f74>] (vfs_read) from [<c02a778c>]
> (SyS_pread64+0x80/0xb8)
> [46886.723306] c7  r8:00000008 r7:c0f09208 r6:c40326c0 r5:c40326c0 r4:fdd887d8
> [46886.723315] c7 [<c02a770c>] (SyS_pread64) from [<c0108620>]
> (ret_fast_syscall+0x0/0x28)
> 
> >
> > >
> > > Signed-off-by: Zhaoyang Huang <huangzhaoyang@gmail.com>
> > > ---
> > >  arch/arm/mm/init.c | 3 ++-
> > >  1 file changed, 2 insertions(+), 1 deletion(-)
> > >
> > > diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
> > > index c2daabb..9c4d938 100644
> > > --- a/arch/arm/mm/init.c
> > > +++ b/arch/arm/mm/init.c
> > > @@ -177,7 +177,8 @@ static void __init zone_sizes_init(unsigned long min, unsigned long max_low,
> > >  #ifdef CONFIG_HAVE_ARCH_PFN_VALID
> > >  int pfn_valid(unsigned long pfn)
> > >  {
> > > -     return memblock_is_map_memory(__pfn_to_phys(pfn));
> > > +     return (pfn > max_pfn) ?
> > > +             false : memblock_is_map_memory(__pfn_to_phys(pfn));
> > >  }
> > >  EXPORT_SYMBOL(pfn_valid);
> > >  #endif
> > > --
> > > 1.9.1
> > >
> > >
> >
> > --
> > RMK's Patch system: https://www.armlinux.org.uk/developer/patches/
> > FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
> > According to speedtest.net: 11.9Mbps down 500kbps up
> 

-- 
Sincerely yours,
Mike.


