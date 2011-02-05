Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 95EEC8D0039
	for <linux-mm@kvack.org>; Sat,  5 Feb 2011 06:40:55 -0500 (EST)
Date: Sat, 5 Feb 2011 12:40:44 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: mmotm 2011-02-04-15-15 uploaded
Message-ID: <20110205114044.GA2317@cmpxchg.org>
References: <201102042349.p14NnQEm025834@imap1.linux-foundation.org>
 <20110205133450.0204834f.sfr@canb.auug.org.au>
 <20110204184300.ebcddedb.akpm@linux-foundation.org>
 <20110205104430.GB2315@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110205104430.GB2315@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Sat, Feb 05, 2011 at 11:44:30AM +0100, Johannes Weiner wrote:
> On Fri, Feb 04, 2011 at 06:43:00PM -0800, Andrew Morton wrote:
> > On Sat, 5 Feb 2011 13:34:50 +1100 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> > > On Fri, 04 Feb 2011 15:15:17 -0800 akpm@linux-foundation.org wrote:
> > > >
> > > > The mm-of-the-moment snapshot 2011-02-04-15-15 has been uploaded to
> > > > 
> > > >    http://userweb.kernel.org/~akpm/mmotm/
> > > > 
> > > > and will soon be available at
> > > > 
> > > >    git://zen-kernel.org/kernel/mmotm.git
> > > 
> > > Just an FYI (origin is the above git repo):
> > > 
> > > $ git remote update origin
> > > Fetching origin
> > > fatal: read error: Connection reset by peer
> > > error: Could not fetch origin
> > 
> > Yes, that's been dead for a while and James isn't responding to email.
> 
> I created an automated tree for myself a while ago.  It has been
> working fine for the last few -mmotm snapshots:
> 
> 	http://git.cmpxchg.org/?p=linux-mmotm.git;a=summary
> 
> Feel free to use that and let me know if something is not right.

Here is the script I use for tree generation, btw:

---
#!/bin/bash

set -e

cd `dirname $0`
CWD="`pwd`"

TAR="broken-out.tar.gz"
URL="http://kernel.org/~akpm/mmotm/$TAR"
TREE_PRIVATE="$CWD/linux-2.6"
TREE_PUBLIC="/pub/git/linux-mmotm.git"

mtime()
{
    stat --printf='%Y' "$@"
}

prepare()
{
    if [ -f "$TAR" ]
    then
	ORG="`mtime $TAR`"
	wget -qN "$URL"
	[ "$ORG" = "`mtime $TAR`" ] && exit 0
    else
	wget -q "$URL"
    fi

    rm -rf broken-out
    tar -xf "$TAR"
    mv .DATE* series broken-out/

    # fix empty binary hunks so git will eat them
    sed -i '/^Binary files.*differ/d' broken-out/*.patch
}

[ "$1" = "-r" ] || prepare

LTAG="v`sed -n 2p broken-out/.DATE`"
ATAG="$LTAG-mmotm-`sed -n 1p broken-out/.DATE`"

cd "$TREE_PRIVATE"
git fetch --tags
git reset --quiet --hard "$LTAG"
git clean --quiet -fdx
rm -rf .git/rebase-apply
git quiltimport --author "mmotm auto import <mm-commits@vger.kernel.org>" --patches "$CWD/broken-out"
git tag -f "$ATAG"
git push --force "$TREE_PUBLIC" --tags
git push --force "$TREE_PUBLIC" --all

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
