From: Nikita Danilov <Nikita@Namesys.COM>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="27+NS3bVKb"
Content-Transfer-Encoding: 7bit
Message-ID: <16418.19751.234876.491644@laputa.namesys.com>
Date: Thu, 5 Feb 2004 17:03:19 +0300
Subject: Re: [PATCH 0/5] mm improvements
In-Reply-To: <4021A6BA.5000808@cyberone.com.au>
References: <16416.64425.172529.550105@laputa.namesys.com>
	<Pine.LNX.4.44.0402041459420.3574-100000@localhost.localdomain>
	<16417.3444.377405.923166@laputa.namesys.com>
	<4021A6BA.5000808@cyberone.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--27+NS3bVKb
Content-Type: text/plain; charset=us-ascii
Content-Description: message body text
Content-Transfer-Encoding: 7bit

Nick Piggin writes:
 > 
 > 
 > Nikita Danilov wrote:
 > 
 > >Hugh Dickins writes:
 > > > On Wed, 4 Feb 2004, Nikita Danilov wrote:
 > > > > Hugh Dickins writes:
 > > > >  > If you go the writepage-while-mapped route (more general gotchas?
 > > > >  > I forget), you'll have to make an exception for shmem_writepage.
 > > > > 
 > > > > May be one can just call try_to_unmap() from shmem_writepage()?
 > > > 
 > > > That sounds much cleaner.  But I've not yet found what tree your
 > > > p12-dont-unmap-on-pageout.patch applies to, so cannot judge it.
 > >
 > >Whole
 > >ftp://ftp.namesys.com/pub/misc-patches/unsupported/extra/2004.02.04/
 > >applies to the 2.6.2-rc2.
 > >
 > >I just updated p12-dont-unmap-on-pageout.patch in-place.
 > >
 > >  
 > >
 > 
 > Sure, I can give this a try. It makes sense.
 > 

To my surprise I have just found that

ftp://ftp.namesys.com/pub/misc-patches/unsupported/extra/2004.02.04/p10-trasnfer-dirty-on-refill.patch

[yes, I know there is a typo in the name.]

patch improves performance quite measurably. It implements a suggestion
made in the comment in refill_inactive_zone():

 			/*
			 * probably it would be useful to transfer dirty bit
			 * from pte to the @page here.
 			 */

To do this page_is_dirty() function is used (the same one as used by
dont-unmap-on-pageout.patch), which is implemented in
check-pte-dirty.patch.

I ran

$ time build.sh 10 11

(attached) and get following elapsed time:

without patch: 3818.320, with patch: 3368.690 (11% improvement).

As I see it, early transfer of dirtiness to the struct page allows to do
more write-back through ->writepages() which is much more efficient way
than single-page ->writepage.

Nikita.

--27+NS3bVKb
Content-Type: text/plain
Content-Disposition: inline;
	filename="build.sh"
Content-Transfer-Encoding: 7bit

#! /bin/sh

nr=$1
pl=$2

path=/usr/src/linux-2.5.59-mm6/

s=$(seq 1 $nr)

function emit()
{
	echo $*
	xtermset -T "$*"
}

emit Removing
rm -fr [0-9]* linux* 2> /dev/null

emit Copying
cp -r $path . 2>/dev/null

emit Cloning
for i in $s ;do
	bk clone linux-2.5.59-mm6 $i >/dev/null 2>/dev/null &
done
wait

emit Unpacking
for i in $s ;do
        cd $i
        bk -r get -q &
        cd ..
done

wait

emit Cleaning
for i in $s ;do
        cd $i
        make mrproper >/dev/null 2>/dev/null &
        cd ..
done

wait

emit Building
for i in $s ;do
        cd $i
        cp ../.config .
        yes | make oldconfig >/dev/null 2>/dev/null
        make -j$pl bzImage >/dev/null 2>/dev/null &
        cd ..
done

wait

emit done.

--27+NS3bVKb--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
