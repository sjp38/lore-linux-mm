Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5B88B6B0031
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 02:49:47 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id p10so36161pdj.31
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 23:49:47 -0800 (PST)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id x3si20995131pbk.203.2014.02.18.23.49.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 23:49:45 -0800 (PST)
Received: by mail-pd0-f180.google.com with SMTP id x10so39708pdj.11
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 23:49:45 -0800 (PST)
Date: Tue, 18 Feb 2014 23:49:42 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: mm: OS boot failed when set command-line kmemcheck=1
In-Reply-To: <5304558F.9050605@huawei.com>
Message-ID: <alpine.DEB.2.02.1402182344001.3551@chino.kir.corp.google.com>
References: <5304558F.9050605@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Vegard Nossum <vegard.nossum@gmail.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 19 Feb 2014, Xishi Qiu wrote:

> Hi all,
> 
> CONFIG_KMEMCHECK=y and set command-line "kmemcheck=1", I find OS 
> boot failed. The kernel is v3.14.0-rc3
> 
> If set "kmemcheck=1 nowatchdog", OS will boot successfully.
> 

I have automated kernel boots that have both "kmemcheck=0" and 
"kmemcheck=1" as the last parameter in the kernel command line every 
night and I've never seen it fail on tip or linux-next before.

So I'm sure I won't be able to reproduce your issue, but it may have 
something to do with your bootloader that isn't described above.  The 
sscanf() really wants to be replaced with kstrtoint().

Could you try this out?

diff --git a/arch/x86/mm/kmemcheck/kmemcheck.c b/arch/x86/mm/kmemcheck/kmemcheck.c
--- a/arch/x86/mm/kmemcheck/kmemcheck.c
+++ b/arch/x86/mm/kmemcheck/kmemcheck.c
@@ -78,10 +78,16 @@ early_initcall(kmemcheck_init);
  */
 static int __init param_kmemcheck(char *str)
 {
+	int val;
+	int ret;
+
 	if (!str)
 		return -EINVAL;
 
-	sscanf(str, "%d", &kmemcheck_enabled);
+	ret = kstrtoint(str, 0, &val);
+	if (ret)
+		return ret;
+	kmemcheck_enabled = val;
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
