Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C074AC282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 13:21:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A2062082F
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 13:20:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="0qLtqDFY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A2062082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CBED08E0042; Mon,  4 Feb 2019 08:20:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C44F58E001C; Mon,  4 Feb 2019 08:20:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE7398E0042; Mon,  4 Feb 2019 08:20:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 83C8F8E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 08:20:58 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id w15so14418629ita.1
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 05:20:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=oI1D2Vjp2HDNRnEFcc6hBhLZ9/+qDh9DJypTZhoEbJE=;
        b=pLSLSMMwBduU6KhiuQuZYVLm2Bv2Qxci1DnTsm4bXUfCFXJlHxREcDHvvfHbSxd+KX
         qgQzMzey9coJPT4a/XF9LD0oFsGG77Px3KKx3vmwADcGv49ls9eNShoEehkzWP13Z6Wp
         YRqX826rLy42trSLI0Ah66u4VizBz/i6Q8dXuTZawZbE+1uGgBfa0unJJek+sUctIjq5
         Zf9C1BlYYYEqYu9nWnUt6OT5M+rUbmZL7dty+nV8gFjzFP6fvR2xzbrws8IIqy+yAf28
         cjiv/MOIN9t4+bR+BGNrW0cOZBZBwN4XBmxX2Z6aSuK1cPq/wdTGrpfFOkS8YMVF6szS
         vLlQ==
X-Gm-Message-State: AHQUAuYacUFqbBqZq93NzTjtDhAE3avu1Ed4qq83jGfTr2xORXZ2gh+y
	IY/D42XOstTX1M3YEwqOFDi1VadyoObsMZtEpFhRHFqmBRIVyAdoaKmE9BlcmZJ/mrqII2izTV9
	ZbddCI0C4C4shfOxfRHqnThRhcWpWh1UnW9AwQGuyAbq73KtcWRgs4qspWE/QDetYSQ==
X-Received: by 2002:a02:a992:: with SMTP id q18mr139453jam.70.1549286458192;
        Mon, 04 Feb 2019 05:20:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ9N17AO8UJZH13B5QT76kwDGIJBXzHCCHW0tY9HsaZUk64X8cFY51Gh0U20ynci5s62UJj
X-Received: by 2002:a02:a992:: with SMTP id q18mr139410jam.70.1549286457391;
        Mon, 04 Feb 2019 05:20:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549286457; cv=none;
        d=google.com; s=arc-20160816;
        b=zUwC6LX/V3DXJUgK2AUFNOq/cxpvkBqKZ2ZvnZujwhn6RaOAxP2whiduXO8N1HoudG
         MdorKbzGQePwjXqlFdmNmzpweEy/ibrQFpmZFosPNeorA1yloPps2PbefkZYd5LpIfY6
         3HbE7d+MYXvR/buYy/wE/pKUvqlMrzeUqtjGcpezYVuxx6UzrAEu7l6Flk3V/I9YkCgU
         +4KDdKWpCct7XnenDTkt0m/aXY4QznFOHjzDrs3/XShPsrYlVdn5b81YiATLBQAwUX7R
         SVhHI6wpfEZPoOFOOhg32zo3iPr7YfwrURW6o1gb7uS752XRjUX+ZSL63/0jvCsAfTnm
         N6ag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=oI1D2Vjp2HDNRnEFcc6hBhLZ9/+qDh9DJypTZhoEbJE=;
        b=QozFFb05Oyy08cJewbF0LC06rPEg7kK8mtCDXJSMOQsqzgmUg4Fmnb+h8MeD/F8vpw
         bVPujlxsxYpSKcoHz80lhXFNISI+dmFqIrfCgEnnl2qKePT19kdwpVaBYFk8Qn4zy7s5
         qwxvjKMau9Kel32inSkSAzt6Fl7tW3r5/it7Ac46teOGX4zdXguvHu3zJeYvIbpz4sIx
         uJWfDxlz4ASVyuryNQBuRCvvJugX4I/UQgvEQRVzQOUCVWOmBL9Ft3YfQy78MsxoudS8
         BB38s9BbRAPx7eKqcoBK4HO3Et3tmzUhbFhZ6xEva6hS62sSXAaGiljWZ9Bu2i9bLh4J
         emNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=0qLtqDFY;
       spf=pass (google.com: domain of dan.carpenter@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=dan.carpenter@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 133si5408ity.52.2019.02.04.05.20.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 05:20:57 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.carpenter@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=0qLtqDFY;
       spf=pass (google.com: domain of dan.carpenter@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=dan.carpenter@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x14DJX5Z179032;
	Mon, 4 Feb 2019 13:20:49 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : mime-version : content-type; s=corp-2018-07-02;
 bh=oI1D2Vjp2HDNRnEFcc6hBhLZ9/+qDh9DJypTZhoEbJE=;
 b=0qLtqDFYgaEWLXUgfkLyLriCN8rQtKbVq4l4is1pQNlsmD9sdVVXSbC5bmYvFgI2iPbc
 TjzvNfhsTFpjR8hSrD6UdQUgdXQUiT/ub81FD/rKsxOi7fu12d+Btc04p8VHLXC2Y5dP
 IEr0eiyZKuIiVO4LJDasTzzavzDFiqQk6+6gd/PMR9lih1HyF9TWSSTbdxIYoeJyJoqW
 kvVxrgnnlB2MESyc1RUN+Ce7bSfZNyXOxVFgJvUEZ1n6JK45kFLeU3NlYGh7xu2enGag
 SK/8b8eELxd9KPc66dlZIm0o6NJWpiLi4XCRE4GrrwQ3zrbIWEcIluII43XCHpnFrTJy tQ== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2120.oracle.com with ESMTP id 2qd98mw283-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 04 Feb 2019 13:20:49 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x14DKmks012763
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 4 Feb 2019 13:20:49 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x14DKlHg024899;
	Mon, 4 Feb 2019 13:20:48 GMT
Received: from kadam (/197.157.0.20)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 04 Feb 2019 13:20:47 +0000
Date: Mon, 4 Feb 2019 16:20:44 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, kernel-janitors@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH] mm/hmm: potential deadlock in nonblocking code
Message-ID: <20190204132043.GA16485@kadam>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
X-Mailer: git-send-email haha only kidding
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9156 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902040106
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There is a deadlock bug when these functions are used in nonblocking
mode.  The else side is only meant to be taken in when the code is
used in blocking mode.  But the way it's written now, if we manage to
take the lock without blocking then we try to take it a second time in
the else statement which leads to a deadlock.

Fixes: a3402cb621c1 ("mm/hmm: improve driver API to work and wait over a range")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 mm/hmm.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index e14e0aa4d2cb..3b97bb087b28 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -207,9 +207,11 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 	update.event = HMM_UPDATE_INVALIDATE;
 	update.blockable = nrange->blockable;
 
-	if (!nrange->blockable && !mutex_trylock(&hmm->lock)) {
-		ret = -EAGAIN;
-		goto out;
+	if (!nrange->blockable) {
+		if (!mutex_trylock(&hmm->lock)) {
+			ret = -EAGAIN;
+			goto out;
+		}
 	} else
 		mutex_lock(&hmm->lock);
 	hmm->notifiers++;
@@ -222,9 +224,11 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 	mutex_unlock(&hmm->lock);
 
 
-	if (!nrange->blockable && !down_read_trylock(&hmm->mirrors_sem)) {
-		ret = -EAGAIN;
-		goto out;
+	if (!nrange->blockable) {
+		if (!down_read_trylock(&hmm->mirrors_sem)) {
+			ret = -EAGAIN;
+			goto out;
+		}
 	} else
 		down_read(&hmm->mirrors_sem);
 	list_for_each_entry(mirror, &hmm->mirrors, list) {
-- 
2.17.1

