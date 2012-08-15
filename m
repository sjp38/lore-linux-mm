Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 2F7916B005D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 05:00:30 -0400 (EDT)
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 28090-09 for <linux-mm@kvack.org>; Wed, 15 Aug 2012 10:00:29 +0100 (BST)
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Subject: RE: [PATCH 02/16] user_ns: use new hashtable implementation
Date: Wed, 15 Aug 2012 09:46:57 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6FB5@saturn3.aculab.com>
In-Reply-To: <87obmchmpu.fsf@xmission.com>
References: <1344961490-4068-1-git-send-email-levinsasha928@gmail.com><1344961490-4068-3-git-send-email-levinsasha928@gmail.com><87txw5hw0s.fsf@xmission.com> <502AF184.4010907@gmail.com><87393phshy.fsf@xmission.com> <502AFCD5.6070104@gmail.com> <87obmchmpu.fsf@xmission.com>
From: "David Laight" <David.Laight@ACULAB.COM>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>, Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

> Yes hash_32 seems reasonable for the uid hash.   With those long hash
> chains I wouldn't like to be on a machine with 10,000 processes with
> each with a different uid, and a processes calling setuid in the fast
> path.
>=20
> The uid hash that we are playing with is one that I sort of wish that
> the hash table could grow in size, so that we could scale up better.

Since uids are likely to be allocated in dense blocks, maybe an
unhashed multi-level lookup scheme might be appropriate.

Index an array with the low 8 (say) bits of the uid.
Each item can be either: =20
  1) NULL =3D> free entry.
  2) a pointer to a uid structure (check uid value).
  3) a pointer to an array to index with the next 8 bits.
(2) and (3) can be differentiated by the low address bit.
I think that is updateable with cmpxchg.

Clearly this is a bad algorithm if uids are all multiples of 2^24
but that is true or any hash function.

	David



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
