Received: by wa-out-1112.google.com with SMTP id m33so428403wag
        for <linux-mm@kvack.org>; Wed, 19 Sep 2007 16:51:47 -0700 (PDT)
Message-ID: <eada2a070709191651i24185d1ep9e0d1829e115ee79@mail.gmail.com>
Date: Wed, 19 Sep 2007 16:51:46 -0700
From: "Tim Pepper" <lnxninja@us.ibm.com>
Subject: Re: [patch 3/8] oom: save zonelist pointer for oom killer calls
In-Reply-To: <alpine.DEB.0.9999.0709191416380.30290@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <alpine.DEB.0.9999.0709181950170.25510@chino.kir.corp.google.com>
	 <alpine.DEB.0.9999.0709190350001.23538@chino.kir.corp.google.com>
	 <alpine.DEB.0.9999.0709190350240.23538@chino.kir.corp.google.com>
	 <alpine.DEB.0.9999.0709190350410.23538@chino.kir.corp.google.com>
	 <Pine.LNX.4.64.0709191204590.2241@schroedinger.engr.sgi.com>
	 <alpine.DEB.0.9999.0709191330520.26978@chino.kir.corp.google.com>
	 <Pine.LNX.4.64.0709191353440.3136@schroedinger.engr.sgi.com>
	 <alpine.DEB.0.9999.0709191416380.30290@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On 9/19/07, David Rientjes <rientjes@google.com> wrote:
> On Wed, 19 Sep 2007, Christoph Lameter wrote:
> > Are there any reasons not to serialize the OOM killer per zone?
>
> That's what this current patchset does, yes.  I agree that it is probably
> better done with a bit in struct zone, however.
>

Removing the kzalloc() would be helpful also for the code's
readability in terms of showing (and remembering in the future) its
correctness.  If I've read this right, as it stands try_set_zone_oom()
works out to behaving in the following ways for the listed return
values:

 ret : behaviour
    0: when is_zone_locked() ret's a 1 (ie: because a zone being OOM'd is
       already marked OOM locked),
       NONE of the current zone(s) are added to the list of OOM zones.
    1: when is_zone_locked() ret's all 0's (ie: b/c no zone(s) being OOM'd are
       already marked OOM locked), and the kzalloc() failed,
       NONE of the current zone(s) are added to the list of OOM zones.
    1: when is_zone_locked() ret's all 0's (ie: b/c no zone(s) being OOM'd are
       already marked OOM locked),
       ALL of the current zone(s) are added to the list of OOM zones.

When no zones in the current zonelist are on the list of OOM zones,
then all the current zones are added to the list of OOM zones...or
none of them depending on how badly OOM'd we are.  Tricky.

If any single zone in the current zonelist matches in the list of OOM
zones, none of the current zones are added to the list of OOM zones.
Given the patch header comments, this was done on purpose.  But
doesn't that leave your list of OOM zones incomplete and open you to
OOM killing in parallel on a given zone?

Or is that all ok in that you're trying to minimise needlessly OOM
killing something when possible but are willing to throw in the towel
when things are tending towards royally hosed?

At any rate this seems complex with subtly varying behaviour that left
me wondering if it really works as advertised.  I imagine without the
kzmalloc and instead checking/setting bits in bitmasks the code would
be cleaner.


Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
