Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FEDCC43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 12:32:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C577220673
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 12:32:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="EsykfS/V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C577220673
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 618126B0007; Mon, 29 Apr 2019 08:32:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C5F36B0008; Mon, 29 Apr 2019 08:32:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 441C36B000A; Mon, 29 Apr 2019 08:32:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id F2B0F6B0007
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 08:32:01 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id i35so5314149plb.7
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 05:32:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:to:cc:subject:from:organization
         :references:date:in-reply-to:message-id:user-agent:mime-version;
        bh=YpLMQQrkPzj0xaZUB7vT4ZsT4KZR9loVYJdQY42icWA=;
        b=tL88pANuIcv+b1H8TitIWSzxKdeUXd/oqY/1A1SD9KqeJ3klXxsql2JS9G4U+EgaCg
         B4MGOPn9uk6MHl0V8wywSLliQl8nXaJVnbzskc9YQLgePKkj1P7MkjSai8UzTmMAhXwX
         mToNGYuDMy6aaDkMN4konmqlFLWaYuE30oU3k3Uis2ddpXbmocRFt+VLaWB/v69YQmRT
         +xgfqxREN1lmj1iAzBCIyq1BiVSiw2fDMnYkX9lgiR5CkPDQtIlIl/s3ROzuF4yCMTbj
         nE74aeVFA8Yi8fgyUHQS32tJb4E9J9LZfOG31KVCKOcgCmcJ0PR/qp0Gnn/Cpnf/VQ3E
         s4AQ==
X-Gm-Message-State: APjAAAWYOiy8ehcs215DWhazgg0TntavPLax9Go7CZeI+YAFxf73ovMz
	aO2E65aKbjGOwYfNgEPqW3Y57uFkueCV3cf/l8yEPQ7bPNqvfNTG9n1czIvphq1etjXVxg6wzH/
	zlMgpqEXxwtaoshtxkuQYysz4VieTiienYFU1d9DHEQ942/DPQBARWUusj9HJJrD+QQ==
X-Received: by 2002:a63:2325:: with SMTP id j37mr4254538pgj.137.1556541121562;
        Mon, 29 Apr 2019 05:32:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjgRUBkAw9zjqUzzlkbgZ/Y7lOjAaMC+/kCBXh+xPuxBbaVf+Im+olEgB0/UTSbyy1MqGZ
X-Received: by 2002:a63:2325:: with SMTP id j37mr4254488pgj.137.1556541120784;
        Mon, 29 Apr 2019 05:32:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556541120; cv=none;
        d=google.com; s=arc-20160816;
        b=eocGfgcImu9DOJEKeOEeUO0VpMtkNZnJplPtI7PDBgnkIORv6sH8ELxKiLY+n8bmuj
         AOcracmOhbxoyXybYfA0RzaAsVXh+89CJRulCAtaDeS/chH5rqCC9788s1MKLOREM54A
         NND1AoVMQiKR0HZ07HtL6rnXMsDX2SGYQr/slAnWq2/51FFjRbSKnIohd3RyVeUEV734
         EpZqBDN6u83OtM4rjG5Xq+ldDzXSdgDSNjwbQgbklaPEadfyEW1NnCB5JIpbhhA8MVqY
         +x/3nlBP897Ci/BEcyE9XSekcjpp3ZK5OUUk1yMIy5pAJVJzlNuhjf/DiF6DzESywStZ
         NdKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :organization:from:subject:cc:to:dkim-signature;
        bh=YpLMQQrkPzj0xaZUB7vT4ZsT4KZR9loVYJdQY42icWA=;
        b=aSaabPk+3wrUoe0pXworXUUMnnff3F1jRn8Byx8bEaeZtod4TMNfZM0WXQ1plJyEPd
         urV1yA/XPOp6UmIdWWETNAA3O1ywXjN8YetTc7lWkiO0w5x6SszsXABPUdjoHwlXh2UD
         z2Ec+uyILVeCqy5zUoj9aC5vgktJ6+NM+/Zm4HECpaBd3bFsVRIiR2mjhsdMekgtoNrF
         RZXxEgn+c68bzRI74E5stVSg8//bu/e1UKTmaObQTkcoHkA0t2dIvvgPIGZNK8UWyfjF
         us0rkcCtJvatWpN5kz/YrQrp7DuNmOU9OoSl+iCUL4AYfF0jlZ88M3USzmJcfOk6x6ge
         rCYg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="EsykfS/V";
       spf=pass (google.com: domain of martin.petersen@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=martin.petersen@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id e92si34829489pld.308.2019.04.29.05.32.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 05:32:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of martin.petersen@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="EsykfS/V";
       spf=pass (google.com: domain of martin.petersen@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=martin.petersen@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3TCJCh9004325;
	Mon, 29 Apr 2019 12:31:58 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=to : cc : subject :
 from : references : date : in-reply-to : message-id : mime-version :
 content-type; s=corp-2018-07-02;
 bh=YpLMQQrkPzj0xaZUB7vT4ZsT4KZR9loVYJdQY42icWA=;
 b=EsykfS/VRtTiG1PT3w2/JyYHxbzIQTpln/YmGWDk5ntThTU/geQoO1SD48MdHk8A9HdN
 5ZqsJGUnFMkz433YFcPCCfQX6H4uort4e6vlGrXXjfXEJAbfujEIjOHsoOHgaOGZIO1+
 oNpocLsQU22CiZ6YZ22v0+Ap5RBRe2Dm76oIKo5G5XfZXkTHKZemHTlCkhnWrxKF8DMF
 /g9d7kJ6btUGWhaZLVj9pPmohy8kv4KqhNCHhyHv+ivZFa8k6jkTNZsxZs8f58Ms+S3I
 HwNc9+O6bQqciEPTHjRhGwuReiGIP99fN3yeUzrhIZbsEcY3VgEBnuZFT5qzPnhD2Scd 6g== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2130.oracle.com with ESMTP id 2s4ckd67xx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 29 Apr 2019 12:31:58 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3TCVXMN182219;
	Mon, 29 Apr 2019 12:31:57 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3030.oracle.com with ESMTP id 2s4yy8xm6m-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 29 Apr 2019 12:31:57 +0000
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x3TCVtt1008055;
	Mon, 29 Apr 2019 12:31:55 GMT
Received: from ca-mkp.ca.oracle.com (/10.159.214.123)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 29 Apr 2019 05:31:55 -0700
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>,
        Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org,
        linux-kernel@vger.kernel.org, lsf@lists.linux-foundation.org,
        linux-mm@kvack.org, Jerome Glisse <jglisse@redhat.com>,
        linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org,
        Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [Lsf] [LSF/MM] Preliminary agenda ? Anyone ... anyone ? Bueller ?
From: "Martin K. Petersen" <martin.petersen@oracle.com>
Organization: Oracle Corporation
References: <20190425200012.GA6391@redhat.com>
	<83fda245-849a-70cc-dde0-5c451938ee97@kernel.dk>
	<503ba1f9-ad78-561a-9614-1dcb139439a6@suse.cz>
	<yq1v9yx2inc.fsf@oracle.com>
	<1556537518.3119.6.camel@HansenPartnership.com>
	<yq1zho911sg.fsf@oracle.com>
	<1556540228.3119.10.camel@HansenPartnership.com>
Date: Mon, 29 Apr 2019 08:31:52 -0400
In-Reply-To: <1556540228.3119.10.camel@HansenPartnership.com> (James
	Bottomley's message of "Mon, 29 Apr 2019 08:17:08 -0400")
Message-ID: <yq11s1l0z7r.fsf@oracle.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1.92 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9241 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904290089
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9241 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904290089
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


James,

> But for this year, I'd just assume the "event partners" checkbox
> covers publication of attendee data to attendees, because if you
> assume the opposite, since you've asked no additional permission of
> your speakers either, that would make publishing the agenda a GDPR
> violation.

Speakers have proposed a topic by posting a message to a public mailing
list. Whereas not all attendees have indicated their desire to attend in
a public forum.

I don't think there's a problem publishing the list of people that sent
an ATTEND. My concern is the ones that didn't. And if the attendee list
is not comprehensive, I am not sure how helpful it is.

From a more practical perspective, I also don't have access to whether
people clicked the "event partners" box or not during registration.
Although I can reach out to LF and see whether I can get access to that
information.

-- 
Martin K. Petersen	Oracle Linux Engineering

