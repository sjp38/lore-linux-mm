Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 5D3746B0062
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 03:58:34 -0400 (EDT)
Subject: [RFC PATCH v2 0/3] mm/fs: Implement faster stable page writes on
 filesystems
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Thu, 01 Nov 2012 00:58:06 -0700
Message-ID: <20121101075805.16153.64714.stgit@blackbox.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, lucho@ionkov.net, tytso@mit.edu, sage@inktank.com, darrick.wong@oracle.com, ericvh@gmail.com, mfasheh@suse.com, dedekind1@gmail.com, adrian.hunter@intel.com, dhowells@redhat.com, sfrench@samba.org, jlbec@evilplan.org, rminnich@sandia.gov
Cc: linux-cifs@vger.kernel.org, jack@suse.cz, martin.petersen@oracle.com, neilb@suse.de, david@fromorbit.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, bharrosh@panasas.com, linux-fsdevel@vger.kernel.org, v9fs-developer@lists.sourceforge.net, ceph-devel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-afs@lists.infradead.org, ocfs2-devel@oss.oracle.com

Hi all,

This patchset makes some key modifications to the original 'stable page writes'
patchset.  First, it provides users (devices and filesystems) of a
backing_dev_info the ability to declare whether or not it is necessary to
ensure that page contents cannot change during writeout, whereas the current
code assumes that this is true.  Second, it relaxes the wait_on_page_writeback
calls so that they only occur if something needs it.  Third, it fixes up (most)
of the remaining filesystems to use this improved conditional-wait logic in the
hopes of providing stable page writes on all filesystems.

It is hoped that (for people not using checksumming devices, anyway) this
patchset will give back unnecessary performance decreases since the original
stable page write patchset went into 3.0.  It seems possible, though, that iscsi
and raid5 may wish to use the new stable page write support to enable zero-copy
writeout.

Unfortunately, it seems that ext3 is still broken wrt stable page writes.  One
workaround would be to use ext4 instead, or avoid the use of ext3.ko + DIF/DIX.
Hopefully it doesn't take long to sort out.

Another thing I noticed is that there are several filesystems that call
wait_on_page_writeback before returning VM_FAULT_LOCKED in their page_mkwrite
delegates.  It might be possible to convert some of these to
wait_for_stable_pages unless there's some other reason that we always want to
wait for writeback.

Finally, if a filesystem wants the VM to help it provide stable pages, it's now
possible to use the *_require_stable_pages() functions to turn that on.  It
might be useful for checksumming data blocks during write.

This patchset has been lightly tested on 3.7.0-rc3 on x64.

--D

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
