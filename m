Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2724EC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 15:23:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC95520663
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 15:23:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Cl10+Swp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC95520663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 725A36B0005; Tue, 13 Aug 2019 11:23:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D6136B0006; Tue, 13 Aug 2019 11:23:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C61B6B0007; Tue, 13 Aug 2019 11:23:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0025.hostedemail.com [216.40.44.25])
	by kanga.kvack.org (Postfix) with ESMTP id 354176B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 11:23:09 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id DF4864859
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 15:23:08 +0000 (UTC)
X-FDA: 75817772856.15.silk40_72b6ddb57494c
X-HE-Tag: silk40_72b6ddb57494c
X-Filterd-Recvd-Size: 6159
Received: from userp2130.oracle.com (userp2130.oracle.com [156.151.31.86])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 15:23:08 +0000 (UTC)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7DFE7tL113127;
	Tue, 13 Aug 2019 15:23:02 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2019-08-05;
 bh=3lnMfPd7Gg7c53hK0P9zvawMvp/Er2oWH5wXpSpk/1A=;
 b=Cl10+SwpcauJ7sUnCom+B5Q1g20dzgbrM+XPg6v26kQrDGDYKCuEh+8gpq0t/aL9k4oN
 z0LM6r5u2R92SS5vkyS39wcDrFw6OCDd9owxpunhIXJys23Vg2CV1YN0mAD0zN7nZCX+
 zAz8x2b4VWT7Eb2HeeLdAf7Li0LFW4wOX0LUXfNGO5RFXvuviY8jHhBCI2R3cHbE8Qhp
 vAexMpBNPsRRS0k8HEYoSRfZOTjBSUXU76PUil5AyyBTtJ0mXJGUSEhIi2YYqllpXPG5
 ImwOsiqTFpEjXHi6C4SwXfSMMJPVZETaW0GBjfB74UJ18HduP1WEd0Nr7nfsZzjyX3Zc jw== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2u9nbtf2y4-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 13 Aug 2019 15:23:02 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7DFDS0K029285;
	Tue, 13 Aug 2019 15:21:01 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3030.oracle.com with ESMTP id 2ubwqrwbdq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 13 Aug 2019 15:21:01 +0000
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x7DFKtnY024258;
	Tue, 13 Aug 2019 15:20:55 GMT
Received: from [10.65.155.174] (/10.65.155.174)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 13 Aug 2019 08:20:54 -0700
Subject: Re: [RFC PATCH 0/2] Add predictive memory reclamation and compaction
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net,
        dan.j.williams@intel.com, osalvador@suse.de, richard.weiyang@gmail.com,
        hannes@cmpxchg.org, arunks@codeaurora.org, rppt@linux.vnet.ibm.com,
        jgg@ziepe.ca, amir73il@gmail.com, alexander.h.duyck@linux.intel.com,
        linux-mm@kvack.org, linux-kernel-mentees@lists.linuxfoundation.org,
        linux-kernel@vger.kernel.org
References: <20190813014012.30232-1-khalid.aziz@oracle.com>
 <20190813140553.GK17933@dhcp22.suse.cz>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <3cb0af00-f091-2f3e-d6cc-73a5171e6eda@oracle.com>
Date: Tue, 13 Aug 2019 09:20:51 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190813140553.GK17933@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9348 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908130158
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9348 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908130158
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/13/19 8:05 AM, Michal Hocko wrote:
> On Mon 12-08-19 19:40:10, Khalid Aziz wrote:
> [...]
>> Patch 1 adds code to maintain a sliding lookback window of (time, numb=
er
>> of free pages) points which can be updated continuously and adds code =
to
>> compute best fit line across these points. It also adds code to use th=
e
>> best fit lines to determine if kernel must start reclamation or
>> compaction.
>>
>> Patch 2 adds code to collect data points on free pages of various orde=
rs
>> at different points in time, uses code in patch 1 to update sliding
>> lookback window with these points and kicks off reclamation or
>> compaction based upon the results it gets.
>=20
> An important piece of information missing in your description is why
> do we need to keep that logic in the kernel. In other words, we have
> the background reclaim that acts on a wmark range and those are tunable=

> from the userspace. The primary point of this background reclaim is to
> keep balance and prevent from direct reclaim. Why cannot you implement
> this or any other dynamic trend watching watchdog and tune watermarks
> accordingly? Something similar applies to kcompactd although we might b=
e
> lacking a good interface.
>=20

Hi Michal,

That is a very good question. As a matter of fact the initial prototype
to assess the feasibility of this approach was written in userspace for
a very limited application. We wrote the initial prototype to monitor
fragmentation and used /sys/devices/system/node/node*/compact to trigger
compaction. The prototype demonstrated this approach has merits.

The primary reason to implement this logic in the kernel is to make the
kernel self-tuning. The more knobs we have externally, the more complex
it becomes to tune the kernel externally. If we can make the kernel
self-tuning, we can actually eliminate external knobs and simplify
kernel admin. Inspite of availability of tuning knobs and large number
of tuning guides for databases and cloud platforms, allocation stalls is
a routinely occurring problem on customer deployments. A best fit line
algorithm shows immeasurable impact on system performance yet provides
measurable improvement and room for further refinement. Makes sense?

Thanks,
Khalid


