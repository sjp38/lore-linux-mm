Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 06A596B029A
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 18:54:17 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id m131-v6so335035itm.5
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 15:54:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z20-v6sor6489529jaa.62.2018.07.02.15.54.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Jul 2018 15:54:16 -0700 (PDT)
MIME-Version: 1.0
References: <1530510723-24814-1-git-send-email-longman@redhat.com>
 <CA+55aFyH6dHw-7R3364dn32J4p7kxT=TqmnuozCn9_Bz-MHhxQ@mail.gmail.com>
 <20180702141811.ef027fd7d8087b7fb2ba0cce@linux-foundation.org> <1530570880.3179.9.camel@HansenPartnership.com>
In-Reply-To: <1530570880.3179.9.camel@HansenPartnership.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 2 Jul 2018 15:54:04 -0700
Message-ID: <CA+55aFzyUb07Lt251bzi4T79oB=M8uypFQ2m__FgnRJUauqd0Q@mail.gmail.com>
Subject: Re: [PATCH v5 0/6] fs/dcache: Track & limit # of negative dentries
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>, linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>

On Mon, Jul 2, 2018 at 3:34 PM James Bottomley
<James.Bottomley@hansenpartnership.com> wrote:
>
> There are still a lot of applications that keep looking up non-existent
> files, so I think it's still beneficial to keep them.  Apparently
> apache still looks for a .htaccess file in every directory it
> traverses, for instance.

.. or git looking for ".gitignore" files in every directory, or any
number of similar things.

Lookie here, for example:

  [torvalds@i7 linux]$ strace -e trace=%file -c git status
  On branch master
  Your branch is up to date with 'origin/master'.

  nothing to commit, working tree clean
  % time     seconds  usecs/call     calls    errors syscall
  ------ ----------- ----------- --------- --------- ----------------
   73.23    0.009066           2      4056         6 open
   23.33    0.002888           2      1294      1189 openat
    1.60    0.000198          13        15         8 access
    0.80    0.000099           2        36        31 lstat
    0.53    0.000066           1        40         6 stat
    0.27    0.000033           8         4           getcwd
    0.11    0.000014          14         1           execve
    0.11    0.000014          14         1           chdir
    0.02    0.000003           3         1         1 readlink
    0.00    0.000000           0         1           unlink
  ------ ----------- ----------- --------- --------- ----------------
  100.00    0.012381                  5449      1241 total

so almost a quarter (1241 of 5449) of the file accesses resulted in
errors (and I think they are all ENOENT).

Negative lookups are *not* some unusual thing.

                   Linus
