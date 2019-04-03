Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA3C7C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 16:08:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5136A206B7
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 16:08:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="SK873dho"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5136A206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0642F6B0010; Wed,  3 Apr 2019 12:08:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 015226B0266; Wed,  3 Apr 2019 12:08:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E468C6B026A; Wed,  3 Apr 2019 12:08:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id C3F8C6B0010
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 12:08:47 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id r21so13983147iod.12
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 09:08:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=6UKrouLSO9YGf202OeHJTSISbS0nfGS6XGw/sMkz2ko=;
        b=Di6D3zn0DD/E1PjIBPU5FcH1jG1QDg2p4ukkPzy1VD6jS4GCHBJ6nDPUN+66Fz9yk3
         o/Wjre8+00U6t+3JzNxNvXh/39EfAIJGr+k53QfbkN+JxBZD4wRDznwZrnV4UpXgGin3
         wm9Wtnot8ydJZXBKkKQvqT0UpkhUSuxy8hZiJXlhhU4oAqWWYTgiVMfHjzQeEIlE2lmI
         eT2mrTOJirxt5dNujK8/N1XqsgwIyeAx/tiBKy6t3rUq1ESYgvU/ikGfk/PA0inaf1gb
         s93lSV5z90lHgTO/IpUvsigrFhUXxd2UTiXmszxtzkpf10UvbXMpRJuUQ9SJHEQAofDa
         rAKw==
X-Gm-Message-State: APjAAAVCBQwm8Q4nJMoYSHy8Dulk6FRXw15x//jbLeWY6/5Nhy/TmGws
	6RGKywH1X/1hk5d3ey2jjNo8wurStowu7XsmknekcHLE/uIZOii5E90isE8WM2uLAW63WHh0W4i
	tq5sDUi3nUjtgPNFPmezCzHuKtNkKM3qdcfq9WugjmspOsd0N+F+O6GxUelDEfiH9Lg==
X-Received: by 2002:a5e:a50e:: with SMTP id 14mr659169iog.63.1554307727571;
        Wed, 03 Apr 2019 09:08:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydXwlUCCot6JA2nKWXp/CjSuPEZOsbxsOFUriIgGGeSGl7RxOvaGv6XXeloH/UfEk4a9fy
X-Received: by 2002:a5e:a50e:: with SMTP id 14mr659111iog.63.1554307726884;
        Wed, 03 Apr 2019 09:08:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554307726; cv=none;
        d=google.com; s=arc-20160816;
        b=l3bo7ALXVyAcHQ8tV+U6NSpjfsEG85GLB0oF6qzPlU5NdBGC9JxWDxs5ZrGzwqQ91p
         pnKdLuGvOS9xipH2ZxHFn8KpOiyzFrLSN+fnyvEqwiO8i9UonIH1JPQszsxdVqXqM1HP
         FsihvZl5apxNhEvMXXG9Lsgm92/C/F9gW7qmXQEKZl4LxQpYrbItdX8m25Sox7ekPUNj
         w/OASZvrPOfNWdZhFaNxLAmBY4va8x8BGEhO9R42Fu2AWt+E+b/H7SgfkUIaoDa/LsUh
         H4zAZX6bci+ijmVpnIUh1PmyGmxYgY56FLUW/1WCqdOOe8FNsdDyUPs5y3ZMhuoLHw8W
         Cb4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=6UKrouLSO9YGf202OeHJTSISbS0nfGS6XGw/sMkz2ko=;
        b=DYeZCc7LdvY4dWDglDCRDSCcMlQa7SONACv6DEG5+NGDn2vkPdYb7zeGYGagIPUNMb
         KPYSttkghgXuyXSxng7k4oLr9Qd2n2X/bCxEZ2ZmsmlfdOnOlDQMGx/C/A5AlP94jjVl
         0ki4yUToShBKbZIFxpWnL7zTrAQ3aX4rRa8BfrmvpSlaFZTCa3xN1rN2JaIphqNUkwQy
         wKjxkzTeL3Z+LhOLUt1ghhxkJEIdJABxzshwGGJKinY39fKtb0FL/yaZSUtlsnesetWL
         0GK0ziNY4Psrk0XFud6T0MrmAXFnBBYqU4Hrb3aNI1YhZt+voKN0u137GLbRXTf5hh8Z
         LYfw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=SK873dho;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id j133si8656576itj.95.2019.04.03.09.08.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 09:08:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=SK873dho;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33G8eDa108963;
	Wed, 3 Apr 2019 16:08:40 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 content-transfer-encoding : in-reply-to; s=corp-2018-07-02;
 bh=6UKrouLSO9YGf202OeHJTSISbS0nfGS6XGw/sMkz2ko=;
 b=SK873dhoOJ098oW9qX/LBUJG1yK+EHo0A6lM9ZNxq9LCVL4PhZTJiPZquZgVmVfDhIU6
 gfc/VHWuIEJMhw1Q0bpaYcik0fQcG2RHWvuyXg4mvjIVhyQ0MFVRGjRVj2Wvr/fQ1/lW
 CpJo6iLUkBVC5nhl1AzOmC0zRf7j3pyofsE7DnWNSgcuQOQxL/IyoZFCUMPv4WSAmkgC
 FpHXzHSyHQfjeB0dA9gV+G9VB4eTpfcmZC3WEu0BVEs3RlYLcfWUee8RbaKrZwckuf07
 tC2VlPnvohyw1xBi+C4k/3YJabuJRoHCOtbfXHwbg74phwl2Txu9+DnPkQOhq/hSlQG/ ZA== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2120.oracle.com with ESMTP id 2rj13q9y2k-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 16:08:40 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33G7ZGm024334;
	Wed, 3 Apr 2019 16:08:40 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3020.oracle.com with ESMTP id 2rm8f66a6g-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 16:08:40 +0000
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x33G8cBU017591;
	Wed, 3 Apr 2019 16:08:38 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 03 Apr 2019 09:08:38 -0700
Date: Wed, 3 Apr 2019 12:09:03 -0400
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, akpm@linux-foundation.org,
        Davidlohr Bueso <dave@stgolabs.net>, kvm@vger.kernel.org,
        Alan Tull <atull@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>,
        linux-fpga@vger.kernel.org, linux-kernel@vger.kernel.org,
        kvm-ppc@vger.kernel.org, linux-mm@kvack.org,
        Alex Williamson <alex.williamson@redhat.com>,
        Moritz Fischer <mdf@kernel.org>, Christoph Lameter <cl@linux.com>,
        linuxppc-dev@lists.ozlabs.org, Wu Hao <hao.wu@intel.com>
Subject: Re: [PATCH 1/6] mm: change locked_vm's type from unsigned long to
 atomic64_t
Message-ID: <20190403160903.5so4okn3ha2tvob3@ca-dmjordan1.us.oracle.com>
References: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
 <20190402204158.27582-2-daniel.m.jordan@oracle.com>
 <4140911c-8193-010b-e8fc-c8b24ffdf423@c-s.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4140911c-8193-010b-e8fc-c8b24ffdf423@c-s.fr>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=911
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904030109
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=949 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904030110
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 06:46:07AM +0200, Christophe Leroy wrote:
> 
> 
> Le 02/04/2019 à 22:41, Daniel Jordan a écrit :
> > Taking and dropping mmap_sem to modify a single counter, locked_vm, is
> > overkill when the counter could be synchronized separately.
> > 
> > Make mmap_sem a little less coarse by changing locked_vm to an atomic,
> > the 64-bit variety to avoid issues with overflow on 32-bit systems.
> 
> Can you elaborate on the above ? Previously it was 'unsigned long', what
> were the issues ?

Sure, I responded to this in another thread from this series.

> If there was such issues, shouldn't there be a first patch
> moving it from unsigned long to u64 before this atomic64_t change ? Or at
> least it should be clearly explain here what the issues are and how
> switching to a 64 bit counter fixes them.

Yes, I can explain the motivation in the next version.

