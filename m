Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D36FC282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 17:33:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E67920821
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 17:33:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="hHbyQcR+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E67920821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E9ED6B0005; Wed, 17 Apr 2019 13:33:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 997B46B0006; Wed, 17 Apr 2019 13:33:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 860A26B0007; Wed, 17 Apr 2019 13:33:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6140F6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 13:33:41 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id 23so21319487qkl.16
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 10:33:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=n6AW0KFZfBWQXIF3BLuGRaqvWHMs7VP7kbUpQyzZLCQ=;
        b=lz+uCSO0dxCkdFGLLlAnoVCFaolnLD/p81XbgGD6iO9zAXdAEZ8rJfy1PlY1M1FCg5
         rKAEHpU8bMXehbaozJv3aHWzsjppOEIr73FQiwOHzCqVP0xZOYEUHMvOSJX4g/OmEkqA
         xsDB3GYdQOKCUPsi8x7u8kDaCg+nTNyqkf3DN1rB2rslTW2LYBzkz9Uj0Up6+guX/aWK
         Ogf0JXPAgjH/+3bhgQXoIXJD2Kvzk1zjmSIFgcHMO4ryH27TYod2MOgvCmwo6hY+kbYQ
         FFzI5cP6SOilwwW/0voQHxLqpm6mvZmrXwfchkwmJQU+YV0Ncgjd3FJW0XHXrqLQYBgl
         BBlw==
X-Gm-Message-State: APjAAAVYTuQZSczyPjyPBWV/QhxRzpFHGonySC106BCd8WsUjNNrsCAQ
	mJCTfcKOjR7Ml2zPcGOKhEqKv0gJmNvSL1Vk3Bl+bKN10+hndf1kE3bJxPTZCM6d4O3daeDbibP
	mMwIE/WGoLtXdsdH5k80vcI4SL+EBCQtVSzRSy1kXiNpJyg7zoMYyTgwXvbBmkEHJdQ==
X-Received: by 2002:a37:a557:: with SMTP id o84mr70068250qke.277.1555522421099;
        Wed, 17 Apr 2019 10:33:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy5n+TggFmaGj9KZ7o6q6TGStUKBnKB3G06RtytzPODUTQhXX7SnLVhjdql96hednzIZusk
X-Received: by 2002:a37:a557:: with SMTP id o84mr70068198qke.277.1555522420428;
        Wed, 17 Apr 2019 10:33:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555522420; cv=none;
        d=google.com; s=arc-20160816;
        b=plw1Ly3MIMexsu7ae/qhvepXrFxnl6TXV0xz72V5AvQyxEJP2RGInz+kA2NlCl3eBz
         aT9AanYYWpc4kBKBm7q6KuOBB2G2Pd83IbmF47x3e+INGaMrqBLBEheVTnPPVqhRV6Kw
         5G3ScKkp4rAz4fIbQgZ9usLjwrHQJaaZ1zQj9kEJpUhkoJ/rLViJotsDefFrju/0uDeZ
         /JuRSJ3F0Z97V43/vxNbYfEU/Y/kjIJ7fsmYW+bXyhaPCSYIVAE+E3X29Ftnk95XAY98
         rA7Tu0qmAl0lhtSRWUyCFGgAHShdgoV2OsvVm/tt+M6e7nwJwdPjZJGkLxcc3b8Jq0Ch
         CHNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=n6AW0KFZfBWQXIF3BLuGRaqvWHMs7VP7kbUpQyzZLCQ=;
        b=shbb0es9OEWvzT+WdHqbezSK2vXh0TuYB1V037bhjkurvmoLmuHGQ/n7JMAWFT3Vsw
         GgtiMnnxAsC7VwszBZq+XS3E8UoDb3pPH17m58+tzBxKUjyi5u9XflTYxgC0dzJFG8xd
         MxX4ZE8tBgJcNfJ2htJ9M6BA5QN36VIqktKEL0bJbtuKyjvjI2SrT/aB4l8IJMJYPgGB
         m7qqELBsKn+Nek1qyY/j/EsBdRzlx1vmh2TOHpv3cFhPYpTrZt1+pAnSUYHy1/2H+0Vz
         cnsTgFvTiQPP4UsOtKzCe6AJ4mXWWlxJEkAZZ/6uHa9S1Dhf1eBGBO4VolDpkqzENm2s
         NrMg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=hHbyQcR+;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id g34si4929816qve.192.2019.04.17.10.33.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 10:33:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=hHbyQcR+;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3HHO5lG087083;
	Wed, 17 Apr 2019 17:33:10 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=n6AW0KFZfBWQXIF3BLuGRaqvWHMs7VP7kbUpQyzZLCQ=;
 b=hHbyQcR+kqdRDbS1HXGo+9Imp9OxI6FtwGiqAsx93fBWBDk7CX4jIet+aGdG1y6ekO8C
 Ti2Do+GqJOBrEB5x67xr+rylVhRtLSeWIi9OyRLpnSoEJ7MlPeL6aVzmxNJeu5NT+0V1
 BY9E+QKXPaHaEI9l3DsywXK8Nwo+WtmwCh/ApxHEC5zeBkDVLjReK64fxhjMPnODAvgB
 BwCVpKk3nhXq1aNu8Vhevz8BvIfHlKJN4MJ+qs43AbfU/nYZ0/Hdd7eOfR2rrofEznbE
 AbhTNE7XqQeWKp1Di9iYW9dQmATPYclZx6QHSHuLjZEw77+iY0XumcJRb03aj+gUI3WP Wg== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2rvwk3vhf0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 17 Apr 2019 17:33:10 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3HHWBSB165901;
	Wed, 17 Apr 2019 17:33:09 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2rv2tvgqhh-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 17 Apr 2019 17:33:09 +0000
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x3HHX7ls006927;
	Wed, 17 Apr 2019 17:33:07 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 17 Apr 2019 10:33:07 -0700
Subject: Re: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame
 Ownership (XPFO)
To: Ingo Molnar <mingo@kernel.org>
Cc: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, keescook@google.com,
        konrad.wilk@oracle.com,
        Juerg Haefliger <juerg.haefliger@canonical.com>,
        deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
        tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
        jcm@redhat.com, boris.ostrovsky@oracle.com,
        iommu@lists.linux-foundation.org, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-security-module@vger.kernel.org,
        Khalid Aziz <khalid@gonehiking.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Andy Lutomirski <luto@kernel.org>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Hansen <dave@sr71.net>,
        Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
        Arjan van de Ven <arjan@infradead.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com>
 <20190417161042.GA43453@gmail.com>
 <e16c1d73-d361-d9c7-5b8e-c495318c2509@oracle.com>
 <20190417170918.GA68678@gmail.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <8d314750-251c-7e6a-7002-5df2462ada6b@oracle.com>
Date: Wed, 17 Apr 2019 11:33:03 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190417170918.GA68678@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9230 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904170117
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9230 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904170117
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/17/19 11:09 AM, Ingo Molnar wrote:
>=20
> * Khalid Aziz <khalid.aziz@oracle.com> wrote:
>=20
>>> I.e. the original motivation of the XPFO patches was to prevent execu=
tion=20
>>> of direct kernel mappings. Is this motivation still present if those =

>>> mappings are non-executable?
>>>
>>> (Sorry if this has been asked and answered in previous discussions.)
>>
>> Hi Ingo,
>>
>> That is a good question. Because of the cost of XPFO, we have to be ve=
ry
>> sure we need this protection. The paper from Vasileios, Michalis and
>> Angelos - <http://www.cs.columbia.edu/~vpk/papers/ret2dir.sec14.pdf>,
>> does go into how ret2dir attacks can bypass SMAP/SMEP in sections 6.1
>> and 6.2.
>=20
> So it would be nice if you could generally summarize external arguments=
=20
> when defending a patchset, instead of me having to dig through a PDF=20
> which not only causes me to spend time that you probably already spent =

> reading that PDF, but I might also interpret it incorrectly. ;-)

Sorry, you are right. Even though that paper explains it well, a summary
is always useful.

>=20
> The PDF you cited says this:
>=20
>   "Unfortunately, as shown in Table 1, the W^X prop-erty is not enforce=
d=20
>    in many platforms, including x86-64.  In our example, the content of=
=20
>    user address 0xBEEF000 is also accessible through kernel address=20
>    0xFFFF87FF9F080000 as plain, executable code."
>=20
> Is this actually true of modern x86-64 kernels? We've locked down W^X=20
> protections in general.
>=20
> I.e. this conclusion:
>=20
>   "Therefore, by simply overwriting kfptr with 0xFFFF87FF9F080000 and=20
>    triggering the kernel to dereference it, an attacker can directly=20
>    execute shell code with kernel privileges."
>=20
> ... appears to be predicated on imperfect W^X protections on the x86-64=
=20
> kernel.
>=20
> Do such holes exist on the latest x86-64 kernel? If yes, is there a=20
> reason to believe that these W^X holes cannot be fixed, or that any fix=
=20
> would be more expensive than XPFO?

Even if physmap is not executable, return-oriented programming (ROP) can
still be used to launch an attack. Instead of placing executable code at
user address 0xBEEF000, attacker can place an ROP payload there. kfptr
is then overwritten to point to a stack-pivoting gadget. Using the
physmap address aliasing, the ROP payload becomes kernel-mode stack. The
execution can then be hijacked upon execution of ret instruction. This
is a gist of the subsection titled "Non-executable physmap" under
section 6.2 and it looked convincing enough to me. If you have a
different take on this, I am very interested in your point of view.

Thanks,
Khalid


