Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03023C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 14:42:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4FD72064A
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 14:42:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="BK/KEpQD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4FD72064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 358756B0005; Wed, 28 Aug 2019 10:42:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3308F6B0006; Wed, 28 Aug 2019 10:42:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 246DB6B000E; Wed, 28 Aug 2019 10:42:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0005.hostedemail.com [216.40.44.5])
	by kanga.kvack.org (Postfix) with ESMTP id 04C406B0005
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 10:42:35 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id B3AF38E7F
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:42:35 +0000 (UTC)
X-FDA: 75872102670.02.hate95_33957ce7ce01f
X-HE-Tag: hate95_33957ce7ce01f
X-Filterd-Recvd-Size: 5587
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:42:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=yJoo2pNqTHPzZm0pkWr+dI3Wt26Ba0eR+Mp1ZOx/yp8=; b=BK/KEpQDOLfLlooeYZXzciO0Ih
	KZ5wNCw5kNMwDJSk0pj1muklV9g/jk0KlTf/SwvC51pBQxSElrumaGBLZuHpQsR7SwxCq34Mot1XJ
	7gmWkyODNqXa17KKkWyyY+vNZDlZzp8AS0rGYTV0F62iEnMONHSEdfZ7H9Etcl0AcgK8bEkyOlbQS
	r0PBEi4ow8fP9ty81WDX7XQCZeJCQtgYLUTRfxVjcLjt8/fVN9n9I3tHAfoOBaAIjsYikU11xALWa
	mL+x3tHE/3UAq8EByi15+eJvdwQ/XwnR0l5pqHnWOA++zmSEHyLZkNeHHwA8OtgBc5w/ZqUGkIWTV
	GmBXUYFw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i2ys3-0005kr-PD; Wed, 28 Aug 2019 14:24:23 +0000
Date: Wed, 28 Aug 2019 07:24:23 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Mark Salyzyn <salyzyn@android.com>
Cc: linux-kernel@vger.kernel.org, kernel-team@android.com,
	Jan Kara <jack@suse.cz>, Stephen Smalley <sds@tycho.nsa.gov>,
	linux-security-module@vger.kernel.org, stable@vger.kernel.org,
	Jonathan Corbet <corbet@lwn.net>, Gao Xiang <gaoxiang25@huawei.com>,
	Chao Yu <yuchao0@huawei.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Latchesar Ionkov <lucho@ionkov.net>,
	Dominique Martinet <asmadeus@codewreck.org>,
	David Howells <dhowells@redhat.com>, Chris Mason <clm@fb.com>,
	Josef Bacik <josef@toxicpanda.com>, David Sterba <dsterba@suse.com>,
	Jeff Layton <jlayton@kernel.org>, Sage Weil <sage@redhat.com>,
	Ilya Dryomov <idryomov@gmail.com>, Steve French <sfrench@samba.org>,
	Tyler Hicks <tyhicks@canonical.com>, Jan Kara <jack@suse.com>,
	Theodore Ts'o <tytso@mit.edu>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Bob Peterson <rpeterso@redhat.com>,
	Andreas Gruenbacher <agruenba@redhat.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Richard Weinberger <richard@nod.at>,
	Dave Kleikamp <shaggy@kernel.org>, Tejun Heo <tj@kernel.org>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	Mark Fasheh <mark@fasheh.com>, Joel Becker <jlbec@evilplan.org>,
	Joseph Qi <joseph.qi@linux.alibaba.com>,
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Phillip Lougher <phillip@squashfs.org.uk>,
	Artem Bityutskiy <dedekind1@gmail.com>,
	Adrian Hunter <adrian.hunter@intel.com>,
	"Darrick J. Wong" <darrick.wong@oracle.com>,
	linux-xfs@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Serge Hallyn <serge@hallyn.com>, James Morris <jmorris@namei.org>,
	Mimi Zohar <zohar@linux.ibm.com>, Paul Moore <paul@paul-moore.com>,
	Eric Paris <eparis@parisplace.org>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"J. Bruce Fields" <bfields@redhat.com>,
	Eric Biggers <ebiggers@google.com>,
	Benjamin Coddington <bcodding@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mathieu Malaterre <malat@debian.org>,
	Vyacheslav Dubeyko <slava@dubeyko.com>,
	Bharath Vedartham <linux.bhar@gmail.com>,
	Jann Horn <jannh@google.com>, Dave Chinner <dchinner@redhat.com>,
	Allison Henderson <allison.henderson@oracle.com>,
	Brian Foster <bfoster@redhat.com>,
	Eric Sandeen <sandeen@sandeen.net>, linux-doc@vger.kernel.org,
	linux-erofs@lists.ozlabs.org, devel@driverdev.osuosl.org,
	v9fs-developer@lists.sourceforge.net, linux-afs@lists.infradead.org,
	linux-btrfs@vger.kernel.org, ceph-devel@vger.kernel.org,
	linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
	ecryptfs@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org, cluster-devel@redhat.com,
	linux-mtd@lists.infradead.org, jfs-discussion@lists.sourceforge.net,
	linux-nfs@vger.kernel.org, ocfs2-devel@oss.oracle.com,
	devel@lists.orangefs.org, linux-unionfs@vger.kernel.org,
	reiserfs-devel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, linux-integrity@vger.kernel.org,
	selinux@vger.kernel.org
Subject: Re: [PATCH v8] Add flags option to get xattr method paired to
 __vfs_getxattr
Message-ID: <20190828142423.GA1955@infradead.org>
References: <20190827150544.151031-1-salyzyn@android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190827150544.151031-1-salyzyn@android.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 27, 2019 at 08:05:15AM -0700, Mark Salyzyn wrote:
> Replace arguments for get and set xattr methods, and __vfs_getxattr
> and __vfs_setaxtr functions with a reference to the following now
> common argument structure:

Yikes.  That looks like a mess.  Why can't we pass a kernel-only
flag in the existing flags field for =E2=82=8B>set and add a flags field
to ->get?  Passing methods by structure always tends to be a mess.

