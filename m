Return-Path: <SRS0=HgWV=RT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47A1BC10F03
	for <linux-mm@archiver.kernel.org>; Sat, 16 Mar 2019 14:49:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E620921903
	for <linux-mm@archiver.kernel.org>; Sat, 16 Mar 2019 14:49:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E620921903
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 37DA96B02D5; Sat, 16 Mar 2019 10:49:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 309026B02D6; Sat, 16 Mar 2019 10:49:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1FAC96B02D7; Sat, 16 Mar 2019 10:49:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA8936B02D5
	for <linux-mm@kvack.org>; Sat, 16 Mar 2019 10:49:02 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id z131so10472278itb.2
        for <linux-mm@kvack.org>; Sat, 16 Mar 2019 07:49:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=/FFaWZSA2YfhUyEx8nHr3wlA+vNq8J4vZ6bnwl4n+5Q=;
        b=NfAJGTberiyssf78fY1PnQoVLORgk3H/73ZpQPoSlIE7V5ehacGSBTOhscvxtubB2y
         6TuQTe5hFAC7Xfa2VVKTVMFw/k9Grn3j/mhC8uMO6d7ptTsFEsNrK238ESqqY1F/MIWR
         zcP2fdzmFLqXwSiysJ8sD3UWWQUvuG/Xvh0OxU85LaHqpo5XJcXjETn26b/C+Zhp5E3w
         da4cmwIXMRSJBSrAYS+kww267SLV3xAobyHCsqtp0oAxhaFrKpdhKk/DJA5XMhScfTL6
         z6xUmHybDTJXaElRnyjOgyzAbOnK9pXp8sq/BYuHmnEEuDAKKkEcDukRMCXvRmnH+Ijn
         eTbg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 33qynxakbabyekl6w770dwbb4z.2aa270ge0dya9f09f.ya8@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=33QyNXAkbABYEKL6w770DwBB4z.2AA270GE0DyA9F09F.yA8@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAWirxJDKNn7kr4fywQfx+QMjKjHUUHnDV5lXDlx2uR10d/gt/TF
	VcyvLOEWALk0N6Pigzq/UDopYznqsH/3NmH3BxtwlImH64+SJyk6KyKnIHTyLG5pG89+zK+ee39
	LLjeiQxjIADdyviH4KAP10QRQJGA+8oQZ8GNhxCQIgSj/YrMteXhRghYAZdBIZ2A=
X-Received: by 2002:a5d:9446:: with SMTP id x6mr4842863ior.236.1552747742604;
        Sat, 16 Mar 2019 07:49:02 -0700 (PDT)
X-Received: by 2002:a5d:9446:: with SMTP id x6mr4842843ior.236.1552747741843;
        Sat, 16 Mar 2019 07:49:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552747741; cv=none;
        d=google.com; s=arc-20160816;
        b=pcNJ6KPc4aYjrMjpYA1xLB8qc+KNI44bgwKCkDoQYjuaITIiWLS6Dw9i38mvMF3UpP
         peftH3bOoyRDplnle8+6+9gYij0o8y2i90dx+WfTGUtQnsFfdCa4gcwXHwuri57Ftnwf
         ipeWFeNb6mdlYdNKmm8xDt+Q0pvCCpY2toYJeyy+otW0HYKciN6SgdtCY6QwvCwOq8hf
         arH1j/RpnAgwQ9IcdWFj3KfBb44KPlwOp9MZ0/0qUM502+9iIf0S6Yv918QMskDpWrft
         1/ZjPUVgRA+mXm1hJ+CJjZODcPbR0TYNa3j4ERtwHBlRWrJz+IJLSvZzmcAjPF0oGpNP
         Rbbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=/FFaWZSA2YfhUyEx8nHr3wlA+vNq8J4vZ6bnwl4n+5Q=;
        b=0RhM0qycriqXnKVRkupl032fDiPUd7CaEIgAwICYJ8KCJ5hSVlkb+NrRHSpVd3WOpS
         y/g02Ja8PY+oRcd8+wIDSJk6tEx7OKu2kOYXsTjOFK6Ire9wbh27gjWwfXB4DCkhfXKY
         aGzQjRraFYzlJupIqV1SfUy/kwqPEkwS0ius0XrCZJVutRmfwZf/AB/o46YnqdxuK3dY
         b2m+niWWAOuUeIOZU8ryxlKXOSIy4cGfDjobQGFI2mbjxPOAe66ee2j2ZxAGvQz6LRac
         BTDWbNYZH7UCaRBeWcDOKXW7Woy9k/39/JJ9sOh1X4uBjgfjvkWoiavpdeuxOH+CB1cA
         K3nA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 33qynxakbabyekl6w770dwbb4z.2aa270ge0dya9f09f.ya8@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=33QyNXAkbABYEKL6w770DwBB4z.2AA270GE0DyA9F09F.yA8@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id q8sor2642282ioi.73.2019.03.16.07.49.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 16 Mar 2019 07:49:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of 33qynxakbabyekl6w770dwbb4z.2aa270ge0dya9f09f.ya8@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 33qynxakbabyekl6w770dwbb4z.2aa270ge0dya9f09f.ya8@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=33QyNXAkbABYEKL6w770DwBB4z.2AA270GE0DyA9F09F.yA8@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqzZSxxCbczTFfnFWh/AGNXppAXdTZUNLfOmpwHI/Q1FLc2y6tADXfO/CbpMJtelbR0Zwlju2MeUiXQOgFQ0DFJJ7YUvTrhD
MIME-Version: 1.0
X-Received: by 2002:a5d:9b95:: with SMTP id r21mr5870876iom.38.1552747741521;
 Sat, 16 Mar 2019 07:49:01 -0700 (PDT)
Date: Sat, 16 Mar 2019 07:49:01 -0700
In-Reply-To: <00000000000016f7d40583d79bd9@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <0000000000008f302105843741ad@google.com>
Subject: Re: WARNING: bad usercopy in fanotify_read
From: syzbot <syzbot+2c49971e251e36216d1f@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, amir73il@gmail.com, cai@lca.pw, 
	crecklin@redhat.com, jack@suse.cz, keescook@chromium.org, 
	linux-api@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

syzbot has bisected this bug to:

commit a8b13aa20afb69161b5123b4f1acc7ea0a03d360
Author: Amir Goldstein <amir73il@gmail.com>
Date:   Thu Jan 10 17:04:36 2019 +0000

     fanotify: enable FAN_REPORT_FID init flag

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=11e78d6f200000
start commit:   a8b13aa2 fanotify: enable FAN_REPORT_FID init flag
git tree:       upstream
final crash:    https://syzkaller.appspot.com/x/report.txt?x=13e78d6f200000
console output: https://syzkaller.appspot.com/x/log.txt?x=15e78d6f200000
kernel config:  https://syzkaller.appspot.com/x/.config?x=e9d91b7192a5e96e
dashboard link: https://syzkaller.appspot.com/bug?extid=2c49971e251e36216d1f
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=1287516f200000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=17ee410b200000

Reported-by: syzbot+2c49971e251e36216d1f@syzkaller.appspotmail.com
Fixes: a8b13aa2 ("fanotify: enable FAN_REPORT_FID init flag")

