Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7A797280251
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 02:25:14 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l138so63183458wmg.3
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 23:25:14 -0700 (PDT)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id i64si21422745wmc.138.2016.09.28.23.25.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 23:25:13 -0700 (PDT)
Received: by mail-wm0-x22f.google.com with SMTP id b4so5586945wmb.0
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 23:25:13 -0700 (PDT)
Date: Thu, 29 Sep 2016 08:25:10 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2 2/3] mm: add LSM hook for writes to readonly memory
Message-ID: <20160929062510.GB21794@gmail.com>
References: <1475103281-7989-1-git-send-email-jann@thejh.net>
 <1475103281-7989-3-git-send-email-jann@thejh.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475103281-7989-3-git-send-email-jann@thejh.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jann@thejh.net>
Cc: security@kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, Eric Paris <eparis@parisplace.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Nick Kralevich <nnk@google.com>, Janis Danisevskis <jdanis@google.com>, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Jann Horn <jann@thejh.net> wrote:

> +/*
> + * subject_cred must be the subjective credentials using which access is
> + * requested.
> + * object_cred must be the objective credentials of the target task at the time
> + * the mm_struct was acquired.
> + * Both of these may be NULL if FOLL_FORCE is unset or FOLL_WRITE is unset.

Hm, I have trouble parsing the first sentence.

> -	return __get_user_pages_locked(current, current->mm, start, nr_pages,
> -				       write, force, pages, vmas, NULL, false,
> -				       FOLL_TOUCH);
> +	return __get_user_pages_locked(current, current->mm, current_cred(),
> +				       current_real_cred(), start,
> +				       nr_pages, write, force, pages, vmas,
> +				       NULL, false, FOLL_TOUCH);

So the parameter passing was disgustig before, and now it became super disgusing! 

Would it improve the code if we added a friendly helper structure (or two if 
that's better) to clean up all the interactions within these various functions?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
