Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09E7CC31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 13:10:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8BE4215EA
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 13:10:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="oYF2y7J+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8BE4215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 420D56B0007; Wed, 19 Jun 2019 09:10:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D19D8E0002; Wed, 19 Jun 2019 09:10:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 299328E0001; Wed, 19 Jun 2019 09:10:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E6C2A6B0007
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 09:10:18 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id o6so823179plk.23
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 06:10:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=kUis8RlFnZIYQf8+xYspbsUmtFv2CDpdqgxk8Iwezmw=;
        b=dF41YjbM/wASLb1juqQNBaugQgHPePKB3+ozjb9gEb08vmScIE2Bkjv9XwBiljiZFI
         6r3du1QreguyDFGxKmTNjeWd+Dw17VDbi3Qkp2GENuC/afFWcTCqOT3HIM27ZM4/t9+y
         fqsVWlt+QP/ntJBT/4T+epRbPnSC8NgJShYSZTgYYlFSpwlVLo618ygCPjPO2VFC1vCU
         k8O7cTfTy/bEsZsg36bKaQYD8zL1phUvnLvyjGd0/WHLXcQ6nWxdVC8Txzx/4Vu2PthA
         ZWkoCH0qEGAGGC2VLOoAywLNgt1vUOuqIf+cgYQ8Lz1pFjRtOtvdjnmIUeJcNjgiKkc3
         /tAw==
X-Gm-Message-State: APjAAAXY2VaO6BSuWCqZsov+i0LSlL/9umWZEe74jfv+lRKAmyxQqvvQ
	bXklllFC2AliRilJ9Suq9P3zXwfyCoEtttJFVkoVUVlNqcK4LVzmXUYlg4KGEUXeo5kOj2W8rck
	z9BE9cEirAEz6BhWPnStLt9prXbnf5C3mn/eKR2L8JIN8cg37LOxWoVJWNYzUz0U=
X-Received: by 2002:a63:63c1:: with SMTP id x184mr1277520pgb.213.1560949818448;
        Wed, 19 Jun 2019 06:10:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBii+fw8t//XyAdIStf38OqubIB44KxFvYCfsA1ybFKbj/1NaUUHFd1pCiO+QQfja9xlix
X-Received: by 2002:a63:63c1:: with SMTP id x184mr1277450pgb.213.1560949817568;
        Wed, 19 Jun 2019 06:10:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560949817; cv=none;
        d=google.com; s=arc-20160816;
        b=xgi1wBELR+mlzMeyfsuNgZfkoPSgXhTB6/CQn3DSuUO+5u/xMZoO/Kx3zQvFjTNvqe
         yj7HUp/8oRHefHnfDtZ4spDEMWG9Xh+InytljVze66mv3O1oaYDtdsqJadOQeHK6qoet
         Dq9kePFaQPmziIM6m1fKP0iBLOaloIXxE3Id95PirbfDGPpOKKY3uNoRTxhR/SwUJZ5K
         ccYNKXGTehKVR0zy9g4LGlxDkT54KijJ2b6F0QXA10Mb8MUvXkuz0n98ray2+H7T056m
         MdCzJHtwe1hvQxDNFQmQyhaSffzSfZq4LG4dnimoHAasU+blNOFN9V954MArQBaagThU
         wORA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=kUis8RlFnZIYQf8+xYspbsUmtFv2CDpdqgxk8Iwezmw=;
        b=AfIWU9t6CzePGcud00nwOqnMXGi4V1oa9iwQznAkBR6aFd5rJrag5rNI8kYH1AHaHR
         WrIeNPO+aXu6mR57twTInqNgT/6kzpc7rFkIrXwWgvRT1Skux/TR7A4CoGCIsGgvSHgz
         JlignTbK5RTK/pMGjqLlf/UbhlnkRcw4N0pF/H2Z2nacD6MpYJjGga+basHqTHRKe7xl
         26N+NXy+JrV7Dq2sQw3z/aqYMUKZ2na+fNU6n27SwIEWE4KqUh4K+qeiHQWVlp9HDjpR
         ueGk0Y/xZaV5rm8JQt4i1nvgjOGHS3EevtrILqyVP70zpqTT/PpPzD31TE8Rh0KsGQIl
         t59Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=oYF2y7J+;
       spf=softfail (google.com: domain of transitioning mchehab+samsung@kernel.org does not designate 198.137.202.133 as permitted sender) smtp.mailfrom=mchehab+samsung@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id w127si4914626pfd.147.2019.06.19.06.10.17
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 19 Jun 2019 06:10:17 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mchehab+samsung@kernel.org does not designate 198.137.202.133 as permitted sender) client-ip=198.137.202.133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=oYF2y7J+;
       spf=softfail (google.com: domain of transitioning mchehab+samsung@kernel.org does not designate 198.137.202.133 as permitted sender) smtp.mailfrom=mchehab+samsung@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:In-Reply-To:Message-ID:Subject:Cc:To:
	From:Date:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=kUis8RlFnZIYQf8+xYspbsUmtFv2CDpdqgxk8Iwezmw=; b=oYF2y7J++7EHsOgMjz4JWm+r3
	EuOm0pUiQxdbAxLc7j9HTZhJldolyFKOBFp7F4PndkRdjuWOpU/S7uSkkXzeAQHpLm8g9Q+j7tjAC
	XAxEm/3JR6uEUSpLsNDpFFx+cJZLH5JoAoXhzAL+pZogkf8306GZfSFyoadtjs7R/h4iEt7Jsx7ow
	I4LDLr+5UvssAjqxSyuWVen7ynH90p3t155tRcxQx3ByAnxH1QZspAXyhGWd24VxaIGfI8BtQBxY6
	OLAW1t5T4H4OfBhS08Ya83/PUuz5nyDqjODRMOT1DXA6vqcdDM+b91y7vMxvEd7V1DITXR2oN1VHM
	uHrahA7OQ==;
Received: from 177.133.86.196.dynamic.adsl.gvt.net.br ([177.133.86.196] helo=coco.lan)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hdaKu-0003lN-SJ; Wed, 19 Jun 2019 13:09:13 +0000
Date: Wed, 19 Jun 2019 10:07:55 -0300
From: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
To: Peter Zijlstra <peterz@infradead.org>, Jonathan Corbet <corbet@lwn.net>
Cc: Daniel Vetter <daniel@ffwll.ch>, Linux Doc Mailing List
 <linux-doc@vger.kernel.org>, Mauro Carvalho Chehab <mchehab@infradead.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Marc Zyngier
 <marc.zyngier@arm.com>, William Breathitt Gray <vilhelm.gray@gmail.com>,
 Jaroslav Kysela <perex@perex.cz>, Greg Kroah-Hartman
 <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>,
 "Naveen N. Rao" <naveen.n.rao@linux.ibm.com>, Anil S Keshavamurthy
 <anil.s.keshavamurthy@intel.com>, "David S. Miller" <davem@davemloft.net>,
 Masami Hiramatsu <mhiramat@kernel.org>, Johannes Thumshirn
 <morbidrsa@gmail.com>, Steffen Klassert <steffen.klassert@secunet.com>,
 Sudip Mukherjee <sudipm.mukherjee@gmail.com>, Andreas =?UTF-8?B?RsOkcmJl?=
 =?UTF-8?B?cg==?= <afaerber@suse.de>, Manivannan Sadhasivam
 <manivannan.sadhasivam@linaro.org>, Rodolfo Giometti
 <giometti@enneenne.com>, Richard Cochran <richardcochran@gmail.com>,
 Thierry Reding <thierry.reding@gmail.com>, Sumit Semwal
 <sumit.semwal@linaro.org>, Gustavo Padovan <gustavo@padovan.org>, Jens
 Wiklander <jens.wiklander@linaro.org>, Kirti Wankhede
 <kwankhede@nvidia.com>, Alex Williamson <alex.williamson@redhat.com>,
 Cornelia Huck <cohuck@redhat.com>, Bartlomiej Zolnierkiewicz
 <b.zolnierkie@samsung.com>, David Airlie <airlied@linux.ie>, Maarten
 Lankhorst <maarten.lankhorst@linux.intel.com>, Maxime Ripard
 <maxime.ripard@bootlin.com>, Sean Paul <sean@poorly.run>, Farhan Ali
 <alifm@linux.ibm.com>, Eric Farman <farman@linux.ibm.com>, Halil Pasic
 <pasic@linux.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Vasily
 Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>,
 Harry Wei <harryxiyou@gmail.com>, Alex Shi <alex.shi@linux.alibaba.com>,
 Evgeniy Polyakov <zbr@ioremap.net>, Jerry Hoemann <jerry.hoemann@hpe.com>,
 Wim Van Sebroeck <wim@linux-watchdog.org>, Guenter Roeck
 <linux@roeck-us.net>, Guan Xuetao <gxt@pku.edu.cn>, Arnd Bergmann
 <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, Bartosz
 Golaszewski <bgolaszewski@baylibre.com>, Andy Shevchenko
 <andy@infradead.org>, Jiri Slaby <jslaby@suse.com>,
 linux-wireless@vger.kernel.org, Linux PCI <linux-pci@vger.kernel.org>,
 "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>,
 platform-driver-x86@vger.kernel.org, Kernel Hardening
 <kernel-hardening@lists.openwall.com>, linux-remoteproc@vger.kernel.org,
 openipmi-developer@lists.sourceforge.net, linux-crypto@vger.kernel.org,
 Linux ARM <linux-arm-kernel@lists.infradead.org>, netdev
 <netdev@vger.kernel.org>, linux-pwm <linux-pwm@vger.kernel.org>, dri-devel
 <dri-devel@lists.freedesktop.org>, kvm@vger.kernel.org, Linux Fbdev
 development list <linux-fbdev@vger.kernel.org>, linux-s390@vger.kernel.org,
 linux-watchdog@vger.kernel.org, "moderated list:DMA BUFFER SHARING
 FRAMEWORK" <linaro-mm-sig@lists.linaro.org>, linux-gpio
 <linux-gpio@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Subject: Re: [PATCH v1 12/22] docs: driver-api: add .rst files from the main
 dir
Message-ID: <20190619075843.3c2464ac@coco.lan>
In-Reply-To: <20190619104239.GM3419@hirez.programming.kicks-ass.net>
References: <cover.1560890771.git.mchehab+samsung@kernel.org>
	<b0d24e805d5368719cc64e8104d64ee9b5b89dd0.1560890772.git.mchehab+samsung@kernel.org>
	<CAKMK7uGM1aZz9yg1kYM8w2gw_cS6Eaynmar-uVurXjK5t6WouQ@mail.gmail.com>
	<20190619072218.4437f891@coco.lan>
	<20190619104239.GM3419@hirez.programming.kicks-ass.net>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-redhat-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Em Wed, 19 Jun 2019 12:42:39 +0200
Peter Zijlstra <peterz@infradead.org> escreveu:

> On Wed, Jun 19, 2019 at 07:22:18AM -0300, Mauro Carvalho Chehab wrote:
> > Hi Daniel,
> > 
> > Em Wed, 19 Jun 2019 11:05:57 +0200
> > Daniel Vetter <daniel@ffwll.ch> escreveu:
> >   
> > > On Tue, Jun 18, 2019 at 10:55 PM Mauro Carvalho Chehab
> > > <mchehab+samsung@kernel.org> wrote:  
> > > > diff --git a/Documentation/gpu/drm-mm.rst b/Documentation/gpu/drm-mm.rst
> > > > index fa30dfcfc3c8..b0f948d8733b 100644
> > > > --- a/Documentation/gpu/drm-mm.rst
> > > > +++ b/Documentation/gpu/drm-mm.rst
> > > > @@ -320,7 +320,7 @@ struct :c:type:`struct file_operations <file_operations>` get_unmapped_area
> > > >  field with a pointer on :c:func:`drm_gem_cma_get_unmapped_area`.
> > > >
> > > >  More detailed information about get_unmapped_area can be found in
> > > > -Documentation/nommu-mmap.rst
> > > > +Documentation/driver-api/nommu-mmap.rst    
> > > 
> > > Random drive-by comment: Could we convert these into hyperlinks within
> > > sphinx somehow, without making them less useful as raw file references
> > > (with vim I can just type 'gf' and it works, emacs probably the same).
> > > -Daniel  
> > 
> > Short answer: I don't know how vim/emacs would recognize Sphinx tags.  
> 
> No, the other way around, Sphinx can recognize local files and treat
> them special. That way we keep the text readable.
> 
> Same with that :c:func:'foo' crap, that needs to die, and Sphinx needs
> to be taught about foo().

Just did a test today at Jon's extension (with is currently on a
separate branch). At least the version that it is there at his automarkup
branch still needs some work, as it currently breaks titles and tables:

	6.4 :c:func:`resync_start()`, :c:func:`resync_finish()`
	-----------------------------------
	/devel/v4l/docs/Documentation/driver-api/md/md-cluster.rst:323: WARNING: Title underline too short.


	/devel/v4l/docs/Documentation/driver-api/serial/tty.rst:74: WARNING: Malformed table.
	Text in column margin in table line 34.

	======================= =======================================================
	:c:func:`open()`                        Called when the line discipline is attached to

-

That's said, once it gets fixed to address those complex cases, a
regex like:

	\bDocumentation/([\w\d\-\_\/]+)\.rst\b

could be converted to :doc: tag. It should be smart enough to convert
the relative paths, as we refer to the files from the git root directory
(with makes a lot sense to me), while Sphinx :doc: use relative patches
from the location where the parsed file is.

Something like the enclosed patch.

Thanks,
Mauro

[PATCH] automarkup.py: convert Documentation/* to hyperlinks

Auto-create hyperlinks when it finds a Documentation/.. occurrence.

Signed-off-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>

diff --git a/Documentation/sphinx/automarkup.py b/Documentation/sphinx/automarkup.py
index 39c8f4d5af82..9d6926b61241 100644
--- a/Documentation/sphinx/automarkup.py
+++ b/Documentation/sphinx/automarkup.py
@@ -9,6 +9,7 @@
 from __future__ import print_function
 import re
 import sphinx
+#import sys		# Just for debug
 
 #
 # Regex nastiness.  Of course.
@@ -31,10 +32,26 @@ RE_literal = re.compile(r'^(\s*)(.*::\s*|\.\.\s+code-block::.*)$')
 #
 RE_whitesp = re.compile(r'^(\s*)')
 
+#
+# Get a documentation reference
+#
+RE_doc_links = re.compile(r'\bDocumentation/([\w\d\-\_\/]+)\.rst\b')
+
+#
+# Doc link false-positives
+#
+RE_false_doc_links = re.compile(r':ref:`\s*Documentation/[\w\d\-\_\/]+\.rst')
+
 def MangleFile(app, docname, text):
     ret = [ ]
     previous = ''
     literal = False
+
+    rel_dir = ''
+
+    for depth in range(0, docname.count('/')):
+        rel_dir += "../"
+
     for line in text[0].split('\n'):
         #
         # See if we might be ending a literal block, as denoted by
@@ -63,7 +80,17 @@ def MangleFile(app, docname, text):
         # Normal line - perform substitutions.
         #
         else:
-            ret.append(RE_function.sub(r'\1:c:func:`\2`\3', line))
+            new_line = RE_function.sub(r'\1:c:func:`\2`\3', line)
+
+            if not RE_false_doc_links.search(new_line):
+                new_line = RE_doc_links.sub(r':doc:`' + rel_dir + r'\1`', new_line)
+
+ #           # Just for debug - should be removed on production
+ #           if new_line != line:
+ #               print ("===>" + new_line, file=sys.stderr)
+
+            ret.append(new_line)
+
         #
         # Might we be starting a literal block?  If so make note of
         # the fact.



