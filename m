Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A00AC6B0038
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 12:56:06 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 204so206944628pge.5
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 09:56:06 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id b6si3432772pfh.241.2017.01.23.09.56.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 09:56:05 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] I/O error handling and fsync()
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170123172500.itzbe7qgzcs6kgh2@thunk.org>
Date: Mon, 23 Jan 2017 12:53:23 -0500
Content-Transfer-Encoding: 7bit
Message-Id: <FB649A96-2DD8-4B45-8A72-1454630E096B@oracle.com>
References: <20170113110959.GA4981@noname.redhat.com> <20170113142154.iycjjhjujqt5u2ab@thunk.org> <20170113160022.GC4981@noname.redhat.com> <87mveufvbu.fsf@notabene.neil.brown.name> <1484568855.2719.3.camel@poochiereds.net> <87o9yyemud.fsf@notabene.neil.brown.name> <1485127917.5321.1.camel@poochiereds.net> <20170123002158.xe7r7us2buc37ybq@thunk.org> <20170123100941.GA5745@noname.redhat.com> <1485173400.2786.5.camel@poochiereds.net> <20170123172500.itzbe7qgzcs6kgh2@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Jeff Layton <jlayton@poochiereds.net>, Kevin Wolf <kwolf@redhat.com>, NeilBrown <neilb@suse.com>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org, Ric Wheeler <rwheeler@redhat.com>


> On Jan 23, 2017, at 12:25 PM, Theodore Ts'o <tytso@mit.edu> wrote:
> 
> On Mon, Jan 23, 2017 at 07:10:00AM -0500, Jeff Layton wrote:
>>>> Well, except for QEMU/KVM, Kevin has already confirmed that using
>>>> Direct I/O is a completely viable solution.  (And I'll add it solves a
>>>> bunch of other problems, including page cache efficiency....)
>> 
>> Sure, O_DIRECT does make this simpler (though it's not always the most
>> efficient way to do I/O). I'm more interested in whether we can improve
>> the error handling with buffered I/O.
> 
> I just want to make sure we're designing a solution that will actually
> be _used_, because it is a good fit for at least one real-world use
> case.
> 
> Is QEMU/KVM using volumes that are stored over NFS really used in the
> real world?

Yes. NFS has worked well for many years in pre-cloud virtualization
environments; in other words, environments that have supported guest
migration for much longer than OpenStack has been around.


> Especially one where you want a huge amount of
> reliability and recovery after some kind network failure?

These are largely data center-grade machine room area networks, not
WANs. Network failures are not as frequent as they used to be.

Most server systems ship with more than one Ethernet device anyway.
Adding a second LAN path between each client and storage targets is
pretty straightforward.


> If we are
> talking about customers who are going to suspend the VM and restart it
> on another server, that presumes a fairly large installation size and
> enough servers that would they *really* want to use a single point of
> failure such as an NFS filer?

You certainly can make NFS more reliable by using a filer that supports
IP-based cluster failover, and has a reasonable amount of redundant
durable storage.

I don't see why we should presume anything about installation size.


> Even if it was a proprietary
> purpose-built NFS filer?  Why wouldn't they be using RADOS and Ceph
> instead, for example?

NFS is a fine inexpensive solution for small deployments and experimental
set ups.

It's much simpler for a single user with no administrative rights to
manage NFS-based files than to deal with creating LUNs or backing
objects, for instance.

Considering the various weirdnesses and inefficiencies involved in
turning an object store into something that has proper POSIX file
semantics, IMO NFS is a known quantity that is straightforward
and a natural fit for some cloud deployments. If it wan't, then
there would be no reason to provide object-to-NFS gateway services.


Wrt O_DIRECT, an NFS client can open the NFS file that backs a virtual
block device with O_DIRECT, and you get the same semantics as reading
or writing to a physical block device. There is no need for the server
to use O_DIRECT as well: the client uses the NFS protocol to control
when the server commits data to durable storage (like, immediately).


--
Chuck Lever



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
