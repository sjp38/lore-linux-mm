Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id B44486B006E
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 10:38:43 -0400 (EDT)
Received: by wibdy8 with SMTP id dy8so76746115wib.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 07:38:43 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bq1si17288885wib.14.2015.03.24.07.38.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Mar 2015 07:38:42 -0700 (PDT)
Message-ID: <1427207914.2412.17.camel@stgolabs.net>
Subject: Re: [PATCH] mm: fix lockdep build in rcu-protected get_mm_exe_file()
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Tue, 24 Mar 2015 07:38:34 -0700
In-Reply-To: <20150323191055.GA10212@redhat.com>
References: <20150320144715.24899.24547.stgit@buzz>
	 <1427134273.2412.12.camel@stgolabs.net> <20150323191055.GA10212@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Mon, 2015-03-23 at 20:10 +0100, Oleg Nesterov wrote:
> "atomic_read(&mm->mm_users) <= 1" looks a bit more "safe". But again,
> I won't insist.

Agreed, it is nicer to do that check, but I have no strong preference
either, perhaps Konstantin or akpm do. Anyway, here's the change that
can be folded in if you guys want to.

Thanks.

8<-------------------------------------------------
diff --git a/kernel/fork.c b/kernel/fork.c
index 98858b5..0c3de2b 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -697,7 +697,7 @@ EXPORT_SYMBOL_GPL(mmput);
 void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file)
 {
 	struct file *old_exe_file = rcu_dereference_protected(mm->exe_file,
-			!atomic_read(&mm->mm_users) || current->in_execve);
+			atomic_read(&mm->mm_users) <= 1);
 
 	if (new_exe_file)
 		get_file(new_exe_file);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
