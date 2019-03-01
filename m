Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33202C10F03
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 10:40:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E49D42084F
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 10:40:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E49D42084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 78BE88E0003; Fri,  1 Mar 2019 05:40:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7115B8E0001; Fri,  1 Mar 2019 05:40:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58DC38E0003; Fri,  1 Mar 2019 05:40:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2AE4B8E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 05:40:29 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id b40so21517262qte.1
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 02:40:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=X9ScJplAWvWlDbSzjugjCe49Pt3V5cvuOs5oHA4MT0c=;
        b=ExdgnJS57x94vFOsdrsy7JuFZ2JH9pp/rDN6ZVpAVZqKrwu9v92hm2yDfcRLGkvxvY
         vpmbRNsLEniWq9CuZNh5Bpnmjz0ChjUyCKtIOQb8UE2zBrj+dNQIQIOa7ivfJOCIMX3I
         /EvDBg2FRuVPttHM42sihDIsHwHvFxCHzMJxt0qCfCfaG1h+SlfzeXk0AnMPNA27nyv3
         Dsq9EEsB9wEYTojWhEge8yncpyEksCmaa4hkBbr0A6HZGzu8Ig3Id8Fk8ljS4vPktL9P
         MPy3zJw/Wh99GgKi6DwqGvg3hI7nDkyJOa58fbXxLUt5VZLMvYKWvHWllT8ftmleq3YF
         3ujg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWX6YaGj5EtN+oLRwaSc8HLmBQS4t0GulAmN5XPvCIxooi2roX3
	d+hzPHkEFxJ8K9oYOhnZGm49/PWvYu3p3ORnXnZDBD1IzI7dEojnJaVgg+FN6o+FDP05nnugqi1
	EpfvtqyFtCdBZMIQspZqMF/YYSWz3mdxCvrFezSuUe9Gz6nCWh7du47SlyOPn3+zYLQ==
X-Received: by 2002:a37:6192:: with SMTP id v140mr3126148qkb.353.1551436828882;
        Fri, 01 Mar 2019 02:40:28 -0800 (PST)
X-Google-Smtp-Source: APXvYqy6O249lyL/9yTqOa+9CSBxM9D6KURRY4Y0VcF5rYm5qjU/K9zXS5ny7CxfL2hIxysZpU+V
X-Received: by 2002:a37:6192:: with SMTP id v140mr3126108qkb.353.1551436827898;
        Fri, 01 Mar 2019 02:40:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551436827; cv=none;
        d=google.com; s=arc-20160816;
        b=rVc5UI34ld5apftmk0nOScCRz81eDTnO2z5+e+NU1WtiKKF62c9WAezihItNiDN23m
         g29ubL3xhtX8NnzJje/5pThxwf8py7GACV40A8FbooO26SAvLrbZrRQVX53/1y/4Gs/m
         0YGonI9orSxIPe/ZqPPugVe844G9Nnwnj2/IJ3lQCUoaSzvnoGWd2jXidVUQtAVNwbZt
         W8cG1sk5iIS4f8ZOx9EibbYMgdw6qhByBV6aZeYjvqpH4u61d9Arw9n1CHdU8Av7Kt5b
         u/y2koax6jAFPnjyPOoj9PmnCS28gN+xUOyVpKSFIvbFqL4dxw6lbqyWgm3SW9HhlA7+
         2MtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=X9ScJplAWvWlDbSzjugjCe49Pt3V5cvuOs5oHA4MT0c=;
        b=UdQK/IixPfjlwaFSmWHZBclL2bIpI9MsN7lov9auK/I1Is6YfG93ET+QAoLw+Ig/FT
         AsCYffV0jk6F/paqDuEYE1nvLdOvq73RjbEKI7+p+9omHVuYEpGybSkRY4WQE2nsZvJP
         IkDvYZSD7oUl5ojgkUplZbFouBvSFi3V08eS3PnA83mOyiUJ/QojTN0o4g1f/g872xfZ
         JdaSFCMLAKh89PYLI38bG7h3FzhLQ4ldhxHGv2iN4VQlZFR2D3vn4PMS7P4Y1yt0wG8Q
         ZQWjc1rcXTkI4BF73/HYncX5gx5+botwS/7xgJY4xeSDOIvaSLfGW3ALdo0ysG4/NmQ7
         UeNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l58si638628qtf.128.2019.03.01.02.40.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 02:40:27 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x21AeJku149115
	for <linux-mm@kvack.org>; Fri, 1 Mar 2019 05:40:27 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qy1tp3yn0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 01 Mar 2019 05:40:27 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Fri, 1 Mar 2019 10:40:23 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 1 Mar 2019 10:40:16 -0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x21AeFVQ50724934
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Fri, 1 Mar 2019 10:40:15 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AEE45A4053;
	Fri,  1 Mar 2019 10:40:15 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id BDCF6A404D;
	Fri,  1 Mar 2019 10:40:13 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.73])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Fri,  1 Mar 2019 10:40:13 +0000 (GMT)
Date: Fri, 1 Mar 2019 12:40:11 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Guillaume Tucker <guillaume.tucker@collabora.com>
Cc: Dan Williams <dan.j.williams@intel.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Michal Hocko <mhocko@suse.com>, Mark Brown <broonie@kernel.org>,
        Tomeu Vizoso <tomeu.vizoso@collabora.com>,
        Matt Hart <matthew.hart@linaro.org>,
        Stephen Rothwell <sfr@canb.auug.org.au>, khilman@baylibre.com,
        enric.balletbo@collabora.com, Nicholas Piggin <npiggin@gmail.com>,
        Dominik Brodowski <linux@dominikbrodowski.net>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Kees Cook <keescook@chromium.org>, Adrian Reber <adrian@lisas.de>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>,
        Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
        Richard Guy Briggs <rgb@redhat.com>,
        "Peter Zijlstra (Intel)" <peterz@infradead.org>, info@kernelci.org
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
References: <5c6702da.1c69fb81.12a14.4ece@mx.google.com>
 <20190215104325.039dbbd9c3bfb35b95f9247b@linux-foundation.org>
 <20190215185151.GG7897@sirena.org.uk>
 <20190226155948.299aa894a5576e61dda3e5aa@linux-foundation.org>
 <CAPcyv4ivjC8fNkfjdFyaYCAjGh7wtvFQnoPpOcR=VNZ=c6d6Rg@mail.gmail.com>
 <20190228151438.fc44921e66f2f5d393c8d7b4@linux-foundation.org>
 <CAPcyv4hDmmK-L=0txw7L9O8YgvAQxZfVFiSoB4LARRnGQ3UC7Q@mail.gmail.com>
 <026b5082-32f2-e813-5396-e4a148c813ea@collabora.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <026b5082-32f2-e813-5396-e4a148c813ea@collabora.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19030110-0012-0000-0000-000002FBB841
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19030110-0013-0000-0000-0000213367FA
Message-Id: <20190301104011.GB5156@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-01_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903010075
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 01, 2019 at 09:25:24AM +0100, Guillaume Tucker wrote:
> On 01/03/2019 00:55, Dan Williams wrote:
> > On Thu, Feb 28, 2019 at 3:14 PM Andrew Morton <akpm@linux-foundation.org> wrote:
> >>
> >> On Tue, 26 Feb 2019 16:04:04 -0800 Dan Williams <dan.j.williams@intel.com> wrote:
> >>
> >>> On Tue, Feb 26, 2019 at 4:00 PM Andrew Morton <akpm@linux-foundation.org> wrote:
> >>>>
> >>>> On Fri, 15 Feb 2019 18:51:51 +0000 Mark Brown <broonie@kernel.org> wrote:
> >>>>
> >>>>> On Fri, Feb 15, 2019 at 10:43:25AM -0800, Andrew Morton wrote:
> >>>>>> On Fri, 15 Feb 2019 10:20:10 -0800 (PST) "kernelci.org bot" <bot@kernelci.org> wrote:
> >>>>>
> >>>>>>>   Details:    https://kernelci.org/boot/id/5c666ea959b514b017fe6017
> >>>>>>>   Plain log:  https://storage.kernelci.org//next/master/next-20190215/arm/multi_v7_defconfig+CONFIG_SMP=n/gcc-7/lab-collabora/boot-am335x-boneblack.txt
> >>>>>>>   HTML log:   https://storage.kernelci.org//next/master/next-20190215/arm/multi_v7_defconfig+CONFIG_SMP=n/gcc-7/lab-collabora/boot-am335x-boneblack.html
> >>>>>
> >>>>>> Thanks.
> >>>>>
> >>>>>> But what actually went wrong?  Kernel doesn't boot?
> >>>>>
> >>>>> The linked logs show the kernel dying early in boot before the console
> >>>>> comes up so yeah.  There should be kernel output at the bottom of the
> >>>>> logs.
> >>>>
> >>>> I assume Dan is distracted - I'll keep this patchset on hold until we
> >>>> can get to the bottom of this.
> >>>
> >>> Michal had asked if the free space accounting fix up addressed this
> >>> boot regression? I was awaiting word on that.
> >>
> >> hm, does bot@kernelci.org actually read emails?  Let's try info@ as well..
> 
> bot@kernelci.org is not person, it's a send-only account for
> automated reports.  So no, it doesn't read emails.
> 
> I guess the tricky point here is that the authors of the commits
> found by bisections may not always have the hardware needed to
> reproduce the problem.  So it needs to be dealt with on a
> case-by-case basis: sometimes they do have the hardware,
> sometimes someone else on the list or on CC does, and sometimes
> it's better for the people who have access to the test lab which
> ran the KernelCI test to deal with it.
> 
> This case seems to fall into the last category.  As I have access
> to the Collabora lab, I can do some quick checks to confirm
> whether the proposed patch does fix the issue.  I hadn't realised
> that someone was waiting for this to happen, especially as the
> BeagleBone Black is a very common platform.  Sorry about that,
> I'll take a look today.
> 
> It may be a nice feature to be able to give access to the
> KernelCI test infrastructure to anyone who wants to debug an
> issue reported by KernelCI or verify a fix, so they won't need to
> have the hardware locally.  Something to think about for the
> future.

Another thing to consider is adding "earlyprintk debug" to the kernel
command line for the boot tests.
 
> >> Is it possible to determine whether this regression is still present in
> >> current linux-next?
> 
> I'll try to re-apply the patch that caused the issue, then see if
> the suggested change fixes it.  As far as the current linux-next
> master branch is concerned, KernelCI boot tests are passing fine
> on that platform.
> 
> Guillaume
> 

-- 
Sincerely yours,
Mike.

