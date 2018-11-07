Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 92B146B0579
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 18:42:38 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id g21-v6so4573130pfg.18
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 15:42:38 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id t11-v6si2219884plq.280.2018.11.07.15.42.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 15:42:37 -0800 (PST)
From: "Williams, Dan J" <dan.j.williams@intel.com>
Subject: Re: [PATCH 7/8] device-dax: Add support for a dax override driver
Date: Wed, 7 Nov 2018 23:42:35 +0000
Message-ID: <3501c074cf14f6a671632c6a6aaffe77cc5b9512.camel@intel.com>
References: <154095556915.3271337.12581429676272726902.stgit@dwillia2-desk3.amr.corp.intel.com>
	 <154095560594.3271337.11620109886861134971.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <154095560594.3271337.11620109886861134971.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-7"
Content-ID: <26905435016A1943B616359192FCFA31@intel.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>

On Tue, 2018-10-30 at 20:13 -0700, Dan Williams wrote:
+AD4- Introduce the 'new+AF8-id' concept for enabling a custom device-drive=
r attach
+AD4- policy for dax-bus drivers. The intended use is to have a mechanism f=
or
+AD4- hot-plugging device-dax ranges into the page allocator on-demand. Wit=
h
+AD4- this in place the default policy of using device-dax for performance
+AD4- differentiated memory can be overridden by user-space policy that can
+AD4- arrange for the memory range to be managed as 'System RAM' with
+AD4- user-defined NUMA and other performance attributes.
+AD4-=20
+AD4- Signed-off-by: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-
+AD4- ---
+AD4-  drivers/dax/bus.c    +AHw-  145 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-=
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+---
+AD4-  drivers/dax/bus.h    +AHw-   10 +-+-+-
+AD4-  drivers/dax/device.c +AHw-   11 +-+---
+AD4-  3 files changed, 156 insertions(+-), 10 deletions(-)
+AD4-=20
+AD4-=20

Here's an incremental fixup for the string matching in this patch, I'll
send a v2 if other review comments come in:

diff --git a/drivers/dax/bus.c b/drivers/dax/bus.c
index 178d76504f79..17af6fbc3be5 100644
--- a/drivers/dax/bus.c
+-+-+- b/drivers/dax/bus.c
+AEAAQA- -39,7 +-39,7 +AEAAQA- static struct dax+AF8-id +ACoAXwBf-dax+AF8-m=
atch+AF8-id(struct dax+AF8-device+AF8-driver +ACo-dax+AF8-drv,
 	lockdep+AF8-assert+AF8-held(+ACY-dax+AF8-bus+AF8-lock)+ADs-
=20
 	list+AF8-for+AF8-each+AF8-entry(dax+AF8-id, +ACY-dax+AF8-drv-+AD4-ids, li=
st)
-		if (strcmp(dax+AF8-id-+AD4-dev+AF8-name, dev+AF8-name) +AD0APQ- 0)
+-		if (sysfs+AF8-streq(dax+AF8-id-+AD4-dev+AF8-name, dev+AF8-name))
 			return dax+AF8-id+ADs-
 	return NULL+ADs-
 +AH0-
+AEAAQA- -60,6 +-60,7 +AEAAQA- static ssize+AF8-t do+AF8-id+AF8-store(struc=
t device+AF8-driver +ACo-drv, const char +ACo-buf,
 +AHs-
 	struct dax+AF8-device+AF8-driver +ACo-dax+AF8-drv +AD0- to+AF8-dax+AF8-dr=
v(drv)+ADs-
 	unsigned int region+AF8-id, id+ADs-
+-	char devname+AFs-DAX+AF8-NAME+AF8-LEN+AF0AOw-
 	struct dax+AF8-id +ACo-dax+AF8-id+ADs-
 	ssize+AF8-t rc +AD0- count+ADs-
 	int fields+ADs-
+AEAAQA- -67,8 +-68,8 +AEAAQA- static ssize+AF8-t do+AF8-id+AF8-store(struc=
t device+AF8-driver +ACo-drv, const char +ACo-buf,
 	fields +AD0- sscanf(buf, +ACI-dax+ACU-d.+ACU-d+ACI-, +ACY-region+AF8-id, =
+ACY-id)+ADs-
 	if (fields +ACEAPQ- 2)
 		return -EINVAL+ADs-
-
-	if (strlen(buf) +- 1 +AD4- DAX+AF8-NAME+AF8-LEN)
+-	sprintf(devname, +ACI-dax+ACU-d.+ACU-d+ACI-, region+AF8-id, id)+ADs-
+-	if (+ACE-sysfs+AF8-streq(buf, devname))
 		return -EINVAL+ADs-
=20
 	mutex+AF8-lock(+ACY-dax+AF8-bus+AF8-lock)+ADs-
+AEAAQA- -99,7 +-100,6 +AEAAQA- static ssize+AF8-t new+AF8-id+AF8-store(str=
uct device+AF8-driver +ACo-drv, const char +ACo-buf,
 +AH0-
 static DRIVER+AF8-ATTR+AF8-WO(new+AF8-id)+ADs-
=20
-
 static ssize+AF8-t remove+AF8-id+AF8-store(struct device+AF8-driver +ACo-d=
rv, const char +ACo-buf,
 		size+AF8-t count)
 +AHs-
