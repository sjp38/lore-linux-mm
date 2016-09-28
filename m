Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id D845928024C
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 19:23:24 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id z142so21573785oig.1
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 16:23:24 -0700 (PDT)
Received: from mail-vk0-x22c.google.com (mail-vk0-x22c.google.com. [2607:f8b0:400c:c05::22c])
        by mx.google.com with ESMTPS id z204si7894844oiz.263.2016.09.28.16.23.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 16:23:14 -0700 (PDT)
Received: by mail-vk0-x22c.google.com with SMTP id z126so59153656vkd.0
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 16:23:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1475103281-7989-3-git-send-email-jann@thejh.net>
References: <1475103281-7989-1-git-send-email-jann@thejh.net> <1475103281-7989-3-git-send-email-jann@thejh.net>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 28 Sep 2016 16:22:53 -0700
Message-ID: <CALCETrUc8VVyPKuGrS7PxBRHCsVhXbXaiEOmwjgHrzTRiXPT9Q@mail.gmail.com>
Subject: Re: [PATCH v2 2/3] mm: add LSM hook for writes to readonly memory
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jann@thejh.net>
Cc: "security@kernel.org" <security@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, Eric Paris <eparis@parisplace.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Nick Kralevich <nnk@google.com>, Janis Danisevskis <jdanis@google.com>, LSM List <linux-security-module@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Sep 28, 2016 at 3:54 PM, Jann Horn <jann@thejh.net> wrote:
> SELinux attempts to make it possible to whitelist trustworthy sources of
> code that may be mapped into memory, and Android makes use of this feature.
> To prevent an attacker from bypassing this by modifying R+X memory through
> /proc/$pid/mem or PTRACE_POKETEXT, it is necessary to call a security hook
> in check_vma_flags().

If selinux policy allows PTRACE_POKETEXT, is it really so bad for that
to result in code execution?


> -struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode)
> +struct mm_struct *proc_mem_open(struct inode *inode,
> +                               const struct cred **object_cred,
> +                               unsigned int mode)
>  {

Why are you passing object_cred all over the place like this?  You
have an inode, and an inode implies a task.

For that matter, would it possibly make sense to use MEMCG's mm->owner
and get rid of object_cred entirely?  I can see this causing issues in
strange threading cases, e.g. accessing your own /proc/$$/mem vs
another thread in your process's.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
