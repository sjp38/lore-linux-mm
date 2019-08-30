Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D78FDC3A59B
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 21:35:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 872D723439
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 21:35:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="knLasF+D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 872D723439
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2159E6B0006; Fri, 30 Aug 2019 17:35:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C77B6B0008; Fri, 30 Aug 2019 17:35:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08E846B000A; Fri, 30 Aug 2019 17:35:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0078.hostedemail.com [216.40.44.78])
	by kanga.kvack.org (Postfix) with ESMTP id D48296B0006
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 17:35:23 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 882B0824CA2C
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 21:35:23 +0000 (UTC)
X-FDA: 75880400526.09.geese19_8652f00a05348
X-HE-Tag: geese19_8652f00a05348
X-Filterd-Recvd-Size: 9097
Received: from aserp2120.oracle.com (aserp2120.oracle.com [141.146.126.78])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 21:35:22 +0000 (UTC)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7ULZEUc075500;
	Fri, 30 Aug 2019 21:35:14 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2019-08-05;
 bh=5JxV0x/cqAp5pWQJzcSayi0vWVKKMysg/b2FgNxOdKw=;
 b=knLasF+DDt10zh6kBLkpjhwY5o9y9CT/PWJiWHFXJ8ttaKCzdRvGTzPeTB5vX2Uq/q7B
 qLDo/DoF6RevirZebgtkbWIVhjrZnxH+b55ybnXP+nTc2xdtcNhzQv4Mi7pD0CEDlFR+
 MAqUq/TpYrct901UrcY0DGTA9Emz+xODLJHs6vl0SqyfW/1PwihmsGYZgvPBUkYrOYoe
 NwOsN4HQhtFlj9+kaCu7M4rdE0FlfQEd92WeRUePIGav3igpILbKZe+T1rc7cl1ZT8aD
 sm+TraerE8bPpCz13yiYazwtPc1LouKnw2bGnT2duu+of+FKfHT0iJmYhNF4aaDEGtDi vw== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2120.oracle.com with ESMTP id 2uqbsgg0cx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 30 Aug 2019 21:35:14 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7ULXiqS132509;
	Fri, 30 Aug 2019 21:35:14 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2uphavr0k5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 30 Aug 2019 21:35:14 +0000
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x7ULZ8Yq005777;
	Fri, 30 Aug 2019 21:35:09 GMT
Received: from [10.154.116.74] (/10.154.116.74)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 30 Aug 2019 14:35:08 -0700
Subject: Re: [RFC PATCH 0/2] Add predictive memory reclamation and compaction
To: Michal Hocko <mhocko@kernel.org>, Bharath Vedartham <linux.bhar@gmail.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net,
        dan.j.williams@intel.com, osalvador@suse.de, richard.weiyang@gmail.com,
        hannes@cmpxchg.org, arunks@codeaurora.org, rppt@linux.vnet.ibm.com,
        jgg@ziepe.ca, amir73il@gmail.com, alexander.h.duyck@linux.intel.com,
        linux-mm@kvack.org, linux-kernel-mentees@lists.linuxfoundation.org,
        linux-kernel@vger.kernel.org
References: <20190813014012.30232-1-khalid.aziz@oracle.com>
 <20190813140553.GK17933@dhcp22.suse.cz>
 <3cb0af00-f091-2f3e-d6cc-73a5171e6eda@oracle.com>
 <20190814085831.GS17933@dhcp22.suse.cz>
 <d3895804-7340-a7ae-d611-62913303e9c5@oracle.com>
 <20190815170215.GQ9477@dhcp22.suse.cz>
 <2668ad2e-ee52-8c88-22c0-1952243af5a1@oracle.com>
 <20190821140632.GI3111@dhcp22.suse.cz>
 <20190826204420.GA16800@bharath12345-Inspiron-5559>
 <20190827061606.GN7538@dhcp22.suse.cz>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <23eca880-d0d7-00f9-cb1b-b2998f2a1dff@oracle.com>
Date: Fri, 30 Aug 2019 15:35:06 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190827061606.GN7538@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9365 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908300206
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9365 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908300206
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/27/19 12:16 AM, Michal Hocko wrote:
> On Tue 27-08-19 02:14:20, Bharath Vedartham wrote:
>> Hi Michal,
>>
>> Here are some of my thoughts,
>> On Wed, Aug 21, 2019 at 04:06:32PM +0200, Michal Hocko wrote:
>>> On Thu 15-08-19 14:51:04, Khalid Aziz wrote:
>>>> Hi Michal,
>>>>
>>>> The smarts for tuning these knobs can be implemented in userspace an=
d
>>>> more knobs added to allow for what is missing today, but we get back=
 to
>>>> the same issue as before. That does nothing to make kernel self-tuni=
ng
>>>> and adds possibly even more knobs to userspace. Something so fundame=
ntal
>>>> to kernel memory management as making free pages available when they=
 are
>>>> needed really should be taken care of in the kernel itself. Moving i=
t to
>>>> userspace just means the kernel is hobbled unless one installs and t=
unes
>>>> a userspace package correctly.
>>>
>>> From my past experience the existing autotunig works mostly ok for a
>>> vast variety of workloads. A more clever tuning is possible and peopl=
e
>>> are doing that already. Especially for cases when the machine is heav=
ily
>>> overcommited. There are different ways to achieve that. Your new
>>> in-kernel auto tuning would have to be tested on a large variety of
>>> workloads to be proven and riskless. So I am quite skeptical to be
>>> honest.
>> Could you give some references to such works regarding tuning the kern=
el?=20
>=20
> Talk to Facebook guys and their usage of PSI to control the memory
> distribution and OOM situations.
>=20
>> Essentially, Our idea here is to foresee potential memory exhaustion.
>> This foreseeing is done by observing the workload, observing the memor=
y
>> usage of the workload. Based on this observations, we make a predictio=
n
>> whether or not memory exhaustion could occur.
>=20
> I understand that and I am not disputing this can be useful. All I do
> argue here is that there is unlikely a good "crystall ball" for most/al=
l
> workloads that would justify its inclusion into the kernel and that thi=
s
> is something better done in the userspace where you can experiment and
> tune the behavior for a particular workload of your interest.
>=20
> Therefore I would like to shift the discussion towards existing APIs an=
d
> whether they are suitable for such an advance auto-tuning. I haven't
> heard any arguments about missing pieces.
>=20

We seem to be in agreement that dynamic tuning is a useful tool. The
question is does that tuning belong in the kernel or in userspace. I see
your point that putting it in userspace allows for faster evolution of
such predictive algorithm than it would be for in-kernel algorithm. I
see following pros and cons with that approach:

+ Keeps complexity of predictive algorithms out of kernel and allows for
faster evolution of these algorithms in userspace.

+ Tuning algorithm can be fine-tuned to specific workloads as appropriate=


- Kernel is not self-tuning and is dependent upon a userspace tool to
perform well in a fundamental area of memory management.

- More knobs get added to already crowded field of knobs to allow for
userspace to tweak mm subsystem for better performance.

As for adding predictive algorithm to kernel, I see following pros and co=
ns:

+ Kernel becomes self-tuning and can respond to varying workloads better.=


+ Allows for number of user visible tuning knobs to be reduced.

- Getting predictive algorithm right is important to ensure none of the
users see worse performance than today.

- Adds a certain level of complexity to mm subsystem

Pushing the burden of tuning kernel to userspace is no different from
where we are today and we still have allocation stall issues after years
of tuning from userspace. Adding more knobs to aid tuning from userspace
just makes the kernel look even more complex to the users. In my
opinion, a self tuning kernel should be the base for long term solution.
We can still export knobs to userspace to allow for users with specific
needs to further fine-tune but the base kernel should work well enough
for majority of users. We are not there at this point. We can discuss
what are the missing pieces to support further tuning from userspace but
is continuing to tweak from userpace the right long term strategy?

Assuming we want to continue to support tuning from userspace instead, I
can't say more knobs are needed right now. We may have enough knobs and
monitors available between /proc/buddyinfo, /sys/devices/system/node and
/proc/sys/vm. Right values for these knobs and their interaction is not
always clear. Maybe we need to simplify these knobs into something more
understandable for average user as opposed to adding more knobs.

--
Khalid





