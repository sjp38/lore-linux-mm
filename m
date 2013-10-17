Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id E66DC6B0035
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 00:04:02 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb12so1733774pbc.8
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 21:04:02 -0700 (PDT)
Message-ID: <1381982635.22110.84.camel@joe-AO722>
Subject: Re: [bug] get_maintainer.pl incomplete output
From: Joe Perches <joe@perches.com>
Date: Wed, 16 Oct 2013 21:03:55 -0700
In-Reply-To: <alpine.DEB.2.02.1310162046090.30995@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1310161738410.10147@chino.kir.corp.google.com>
	 <alpine.DEB.2.02.1310162046090.30995@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, Michal Hocko <mhocko@suse.cz>, "Kirill A.
 Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 2013-10-16 at 20:51 -0700, David Rientjes wrote:
> Hi Joe,

Hi David.

> I haven't looked closely at scripts/get_maintainer.pl, but I recently 
> wrote a patch touching mm/vmpressure.c and it doesn't list the file's 
> author, Anton Vorontsov <anton.vorontsov@linaro.org>.
> 
> Even when I do scripts/get_maintainer.pl -f mm/vmpressure.c, his entry is 
> missing and git blame attributs >90% of the lines to his authorship.
> 
> $ ./scripts/get_maintainer.pl -f mm/vmpressure.c 
> Tejun Heo <tj@kernel.org> (commit_signer:6/7=86%)
> Michal Hocko <mhocko@suse.cz> (commit_signer:5/7=71%)
> Andrew Morton <akpm@linux-foundation.org> (commit_signer:4/7=57%)
> Li Zefan <lizefan@huawei.com> (commit_signer:3/7=43%)
> "Kirill A. Shutemov" <kirill@shutemov.name> (commit_signer:1/7=14%)
> linux-mm@kvack.org (open list:MEMORY MANAGEMENT)
> linux-kernel@vger.kernel.org (open list)
> 
> Any ideas?

get_maintainer has a lot of options.

get_maintainer tries to find people that are either
listed in the MAINTAINERS file or that have recently
(in the last year by default) worked on the file.

If you want to find all authors, use the --git-blame option

It's not the default because it can take quite awhile to run.

If you always want --git-blame added, use a .get_maintainer.conf
file to override the default options.

$ time ./scripts/get_maintainer.pl -f --git-blame mm/vmpressure.c
Tejun Heo <tj@kernel.org> (commit_signer:6/7=86%,commits:5/6=83%)
Michal Hocko <mhocko@suse.cz> (commit_signer:5/7=71%,authored lines:22/387=6%,commits:5/6=83%)
Andrew Morton <akpm@linux-foundation.org> (commit_signer:4/7=57%,commits:4/6=67%)
Li Zefan <lizefan@huawei.com> (commit_signer:3/7=43%,commits:2/6=33%)
"Kirill A. Shutemov" <kirill@shutemov.name> (commit_signer:1/7=14%,commits:1/6=17%)
Anton Vorontsov <anton.vorontsov@linaro.org> (authored lines:354/387=91%)
linux-mm@kvack.org (open list:MEMORY MANAGEMENT)
linux-kernel@vger.kernel.org (open list)

real	0m28.529s
user	0m25.400s
sys	0m0.764s

The --help option is moderately descriptive.
If you think it needs to be better, please say how.

cheers, Joe

$ ./scripts/get_maintainer.pl --help
usage: ./scripts/get_maintainer.pl [options] patchfile
       ./scripts/get_maintainer.pl [options] -f file|directory
version: 0.26

MAINTAINER field selection options:
  --email => print email address(es) if any
    --git => include recent git *-by: signers
    --git-all-signature-types => include signers regardless of signature type
        or use only (Signed-off-by:|Reviewed-by:|Acked-by:) signers (default: 0)
    --git-fallback => use git when no exact MAINTAINERS pattern (default: 1)
    --git-chief-penguins => include (Linus Torvalds)
    --git-min-signatures => number of signatures required (default: 1)
    --git-max-maintainers => maximum maintainers to add (default: 5)
    --git-min-percent => minimum percentage of commits required (default: 5)
    --git-blame => use git blame to find modified commits for patch or file
    --git-since => git history to use (default: 1-year-ago)
    --hg-since => hg history to use (default: -365)
    --interactive => display a menu (mostly useful if used with the --git option)
    --m => include maintainer(s) if any
    --n => include name 'Full Name <addr@domain.tld>'
    --l => include list(s) if any
    --s => include subscriber only list(s) if any
    --remove-duplicates => minimize duplicate email names/addresses
    --roles => show roles (status:subsystem, git-signer, list, etc...)
    --rolestats => show roles and statistics (commits/total_commits, %)
    --file-emails => add email addresses found in -f file (default: 0 (off))
  --scm => print SCM tree(s) if any
  --status => print status if any
  --subsystem => print subsystem name if any
  --web => print website(s) if any

Output type options:
  --separator [, ] => separator for multiple entries on 1 line
    using --separator also sets --nomultiline if --separator is not [, ]
  --multiline => print 1 entry per line

Other options:
  --pattern-depth => Number of pattern directory traversals (default: 0 (all))
  --keywords => scan patch for keywords (default: 1)
  --sections => print all of the subsystem sections with pattern matches
  --mailmap => use .mailmap file (default: 1)
  --version => show version
  --help => show this help information

Default options:
  [--email --nogit --git-fallback --m --n --l --multiline -pattern-depth=0
   --remove-duplicates --rolestats]

Notes:
  Using "-f directory" may give unexpected results:
      Used with "--git", git signators for _all_ files in and below
          directory are examined as git recurses directories.
          Any specified X: (exclude) pattern matches are _not_ ignored.
      Used with "--nogit", directory is used as a pattern match,
          no individual file within the directory or subdirectory
          is matched.
      Used with "--git-blame", does not iterate all files in directory
  Using "--git-blame" is slow and may add old committers and authors
      that are no longer active maintainers to the output.
  Using "--roles" or "--rolestats" with git send-email --cc-cmd or any
      other automated tools that expect only ["name"] <email address>
      may not work because of additional output after <email address>.
  Using "--rolestats" and "--git-blame" shows the #/total=% commits,
      not the percentage of the entire file authored.  # of commits is
      not a good measure of amount of code authored.  1 major commit may
      contain a thousand lines, 5 trivial commits may modify a single line.
  If git is not installed, but mercurial (hg) is installed and an .hg
      repository exists, the following options apply to mercurial:
          --git,
          --git-min-signatures, --git-max-maintainers, --git-min-percent, and
          --git-blame
      Use --hg-since not --git-since to control date selection
  File ".get_maintainer.conf", if it exists in the linux kernel source root
      directory, can change whatever get_maintainer defaults are desired.
      Entries in this file can be any command line argument.
      This file is prepended to any additional command line arguments.
      Multiple lines and # comments are allowed.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
