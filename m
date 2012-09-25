Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 0E7396B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 15:22:33 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <d2355756-7b4d-4b23-89ce-602c3451ac68@default>
Date: Tue, 25 Sep 2012 12:22:14 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] mm: add support for zsmalloc and zcache
References: <1346794486-12107-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20120921161252.GV11266@suse.de>
 <15c1d12a-0e29-478f-97e0-ee4063e2cba5@default> <505DBDC5.3010503@gmail.com>
 <505DBF72.3000208@gmail.com>
In-Reply-To: <505DBF72.3000208@gmail.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Sasha Levin [mailto:levinsasha928@gmail.com]
> Subject: Re: [RFC] mm: add support for zsmalloc and zcache

Sorry for delayed response!
=20
> On 09/22/2012 03:31 PM, Sasha Levin wrote:
> > On 09/21/2012 09:14 PM, Dan Magenheimer wrote:
> >>>> +#define MAX_CLIENTS 16
> >>>>
> >>>> Seems a bit arbitrary. Why 16?
> >> Sasha Levin posted a patch to fix this but it was tied in to
> >> the proposed KVM implementation, so was never merged.
> >>
> >
> > My patch changed the max pools per client, not the maximum amount of cl=
ients.
> > That patch has already found it's way in.
> >
> > (MAX_CLIENTS does look like an arbitrary number though).
>=20
> btw, while we're on the subject of KVM, the implementation of tmem/kvm wa=
s
> blocked due to insufficient performance caused by the lack of multi-page
> ops/batching.

Hmmm... I recall that was an unproven assertion.  The tmem/kvm
implementation was not exposed to any wide range of workloads
IIRC?  Also, the WasActive patch is intended to reduce the problem
that multi-guest high volume reads would provoke, so any testing
without that patch may be moot.
=20
> Are there any plans to make it better in the future?

If it indeed proves to be a problem, the ramster-merged zcache
(aka zcache2) should be capable of managing a "split" zcache
implementation, i.e. zcache executing in the guest and "overflowing"
page cache pages to the zcache in the host, which should at least
ameliorate most of Avi's concern.  I personally have no plans
to implement that, but would be willing to assist if others
attempt to implement it.

The other main concern expressed by the KVM community, by
Andrea, was zcache's lack of ability to "overflow" frontswap
pages in the host to a real swap device.  The foundation
for that was one of the objectives of the zcache2 redesign;
I am working on a "yet-to-be-posted" patch built on top of zcache2
that will require some insight and review from MM experts.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
