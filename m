Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B7BAC04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 18:30:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F244A208C3
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 18:30:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F244A208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 506076B0008; Mon, 13 May 2019 14:30:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B6E86B000A; Mon, 13 May 2019 14:30:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3CC656B000C; Mon, 13 May 2019 14:30:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1D70F6B0008
	for <linux-mm@kvack.org>; Mon, 13 May 2019 14:30:58 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id t51so15224753qtb.11
        for <linux-mm@kvack.org>; Mon, 13 May 2019 11:30:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=j6peJFl4q7bqwYp959siWYBsnvXU8q7u0HMv/fDdcps=;
        b=QsDEZ5m7q4aE1FlnuUmqORoVul61pB1cw33Y2LLX6DX6/LS0qGk98ENXneBS3pKzA1
         OWDVJaA4WvA1HwqK1j6dGH6P2SYIywPFBxZm8+tZltLGrG9nqZ2m0U3vg6fE7ZMKuQ6o
         KQSN++cvFVLgN63FrI7evkOptuvYX9JBK49QtwqczbhYIxVFsKpbK3jjjL/OSI+e2Oms
         8m+MbsroQ5T/KOtpZA5C0pTm1w/1tyvbI2w2OnMPajnjOr7CwTY1Dfn9HTB4dXvg08WU
         3f/CGW8tno04AspRERGAE7nxFz3P3PVOOgOKlwo+8B1TntTVxmGerOoIL6G4d9R3St6P
         6HoA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUg1wR68yw/3x8KwNLjwAZgiHhYjG2B1vQyE+QCyC1az2IYgnMN
	cb3gMwgdPoLDW9C/CZcbWecTyYU0BvsJxDtC93nlFW+QNGbAZSwQfMf7hFRB30zlmOI0wlyXucm
	6k8nC6Evae3eJ6sCJYvYkIv+mUy32MKaL0tpvVCMi5cQgM8ObTfcs1rT7Pw5Gv2I=
X-Received: by 2002:ac8:2bbb:: with SMTP id m56mr8632987qtm.298.1557772257785;
        Mon, 13 May 2019 11:30:57 -0700 (PDT)
X-Received: by 2002:ac8:2bbb:: with SMTP id m56mr8632905qtm.298.1557772256892;
        Mon, 13 May 2019 11:30:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557772256; cv=none;
        d=google.com; s=arc-20160816;
        b=C0SAQUg7Vz9+BvM8oKeV/VEdKLC742u+xHEhrBBnW09BPGPXWYdQRNyHMCWyJdsjpc
         zqWhni3IDfoKVpheUjRXTNzaMU+WBKK953AacHq+TEZBKIW3HOWaF3I0DEhdUknuT3ZL
         CWH4u+SBPlklvNgryJRhZrUbpwEdFspT9InHxEPJ5DOt6wDQACSM6TovK+CySS5iGUu5
         lmJAwcjBGBhb28pw5ZmcDXeYncoqOErs+vd5Kn7T+EBLbmm3NhVMwF+4sbvYGFVidxqx
         2pVLWizxaKwHcT2JKGVliC8pRPY3DZKZJ6xbo/7H0J6Wb+f9OopfO9jV+ioQGsdBnro3
         IffQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=j6peJFl4q7bqwYp959siWYBsnvXU8q7u0HMv/fDdcps=;
        b=ot+y8OuAfHYMCKg1aNfAuMpEC3knZU7fcPDPncllTh3ejiK2iGZqQmGtGu0IiWgTnW
         2IDph50sEmoh/dgBYz5mdYi2k18BswIQ8HYzGjqKCLFOFddPtkZila5ds8o/GaW1UGJ7
         BpJeCVeKNnwdMNzLoACNqssJeM3591gWx06o9iBVygS0J3OUb2emWPEvtfoamUqiOWsf
         5crBF00AwXHpgxp5OQWDPtONdLP+uCqZxBlJT3ITU6meovn18Vb/pMMI2QIgstlkVYGj
         iZRZSHlLu0dQizKz8g6K70f3418toKBvYmABt4C6CSzEshxSYOdlyogsT1RkimRB/ORw
         8V/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y72sor3610219qka.26.2019.05.13.11.30.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 May 2019 11:30:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqySj2p3gNrrRMfzGy0ZnXbY7Vu04dcTWAdXGxO5XYpqMnB+WUzkGAPF4aPuYUMMf8ETKWiqoQ==
X-Received: by 2002:a37:ad12:: with SMTP id f18mr22659478qkm.145.1557772256575;
        Mon, 13 May 2019 11:30:56 -0700 (PDT)
Received: from dennisz-mbp ([2620:10d:c091:500::3:b635])
        by smtp.gmail.com with ESMTPSA id w195sm7342975qkb.54.2019.05.13.11.30.55
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 11:30:55 -0700 (PDT)
Date: Mon, 13 May 2019 14:30:53 -0400
From: Dennis Zhou <dennis@kernel.org>
To: =?utf-8?B?5Lmx55+z?= <zhangliguang@linux.alibaba.com>
Cc: Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org,
	cgroups@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH] fs/writeback: Attach inode's wb to root if needed
Message-ID: <20190513183053.GA73423@dennisz-mbp>
References: <1557389033-39649-1-git-send-email-zhangliguang@linux.alibaba.com>
 <20190509164802.GV374014@devbig004.ftw2.facebook.com>
 <a5bb3773-fef5-ce2b-33b9-18e0d49c33c4@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a5bb3773-fef5-ce2b-33b9-18e0d49c33c4@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Liguang,

On Fri, May 10, 2019 at 09:54:27AM +0800, 乱石 wrote:
> Hi Tejun,
> 
> 在 2019/5/10 0:48, Tejun Heo 写道:
> > Hi Tejun,
> > 
> > On Thu, May 09, 2019 at 04:03:53PM +0800, zhangliguang wrote:
> > > There might have tons of files queued in the writeback, awaiting for
> > > writing back. Unfortunately, the writeback's cgroup has been dead. In
> > > this case, we reassociate the inode with another writeback cgroup, but
> > > we possibly can't because the writeback associated with the dead cgroup
> > > is the only valid one. In this case, the new writeback is allocated,
> > > initialized and associated with the inode. It causes unnecessary high
> > > system load and latency.
> > > 
> > > This fixes the issue by enforce moving the inode to root cgroup when the
> > > previous binding cgroup becomes dead. With it, no more unnecessary
> > > writebacks are created, populated and the system load decreased by about
> > > 6x in the online service we encounted:
> > >      Without the patch: about 30% system load
> > >      With the patch:    about  5% system load
> > Can you please describe the scenario with more details?  I'm having a
> > bit of hard time understanding the amount of cpu cycles being
> > consumed.
> > 
> > Thanks.
> 
> Our search line reported a problem, when containerA was removed,
> containerB and containerC's system load were up to 30%.
> 
> We record the trace with 'perf record cycles:k -g -a', found that wb_init
> was the hotspot function.
> 
> Function call:
> 
> generic_file_direct_write
>    filemap_write_and_wait_range
>       __filemap_fdatawrite_range
>          wbc_attach_fdatawrite_inode
>             inode_attach_wb
>                __inode_attach_wb
>                   wb_get_create
>             wbc_attach_and_unlock_inode
>                if (unlikely(wb_dying(wbc->wb)))
>                   inode_switch_wbs
>                      wb_get_create
>                         ; Search bdi->cgwb_tree from memcg_css->id
>                         ; OR cgwb_create
>                            kmalloc
>                            wb_init       // hot spot
>                            ; Insert to bdi->cgwb_tree, mmecg_css->id as key
> 
> We discussed it through, base on the analysis:  When we running into the
> issue, there is cgroups are being deleted. The inodes (files) that were
> associated with these cgroups have to switch into another newly created
> writeback. We think there are huge amount of inodes in the writeback list
> that time. So we don't think there is anything abnormal. However, one
> thing we possibly can do: enforce these inodes to BDI embedded wirteback
> and we needn't create huge amount of writebacks in that case, to avoid
> the high system load phenomenon. We expect correct wb (best candidate) is
> picked up in next round.
> 
> Thanks,
> Liguang
> 
> > 
> 

If I understand correctly, this is mostlikely caused by a file shared by
cgroup A and cgroup B. This means cgroup B is doing direct io against
the file owned by the dying cgroup A. In this case, the code tries to do
a wb switch. However, it fails to reallocate the wb as it's deleted and
for the original cgrouip A's memcg id.

I think the below may be a better solution. Could you please test it? If
it works, I'll spin a patch with a more involved description.

Thanks,
Dennis

---
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 36855c1f8daf..fb331ea2a626 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -577,7 +577,7 @@ void wbc_attach_and_unlock_inode(struct writeback_control *wbc,
 	 * A dying wb indicates that the memcg-blkcg mapping has changed
 	 * and a new wb is already serving the memcg.  Switch immediately.
 	 */
-	if (unlikely(wb_dying(wbc->wb)))
+	if (unlikely(wb_dying(wbc->wb)) && !css_is_dying(wbc->wb->memcg_css))
 		inode_switch_wbs(inode, wbc->wb_id);
 }
 
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 72e6d0c55cfa..685563ed9788 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -659,7 +659,7 @@ struct bdi_writeback *wb_get_create(struct backing_dev_info *bdi,
 
 	might_sleep_if(gfpflags_allow_blocking(gfp));
 
-	if (!memcg_css->parent)
+	if (!memcg_css->parent || css_is_dying(memcg_css))
 		return &bdi->wb;
 
 	do {

