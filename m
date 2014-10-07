Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id E393C6B0069
	for <linux-mm@kvack.org>; Tue,  7 Oct 2014 13:26:30 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id b13so9881033wgh.10
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 10:26:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l6si6919679wia.1.2014.10.07.10.26.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Oct 2014 10:26:29 -0700 (PDT)
Date: Tue, 7 Oct 2014 18:25:48 +0100
From: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH 10/17] mm: rmap preparation for remap_anon_pages
Message-ID: <20141007172547.GQ2404@work-vm>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
 <1412356087-16115-11-git-send-email-aarcange@redhat.com>
 <CA+55aFx++R42L75ooE=Fmaem73=V=q7f6pYTcALxgrA1y98G-A@mail.gmail.com>
 <20141006085540.GD2336@work-vm>
 <20141006164156.GA31075@redhat.com>
 <CA+55aFxAOYBny+QwXfkPy-P3rs-RPr5SLYLcPNBiFO3waBXtQA@mail.gmail.com>
 <20141007170731.GO2404@work-vm>
 <54341F77.6060400@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54341F77.6060400@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, qemu-devel@nongnu.org, KVM list <kvm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

* Paolo Bonzini (pbonzini@redhat.com) wrote:
> Il 07/10/2014 19:07, Dr. David Alan Gilbert ha scritto:
> >> > 
> >> > So I'd *much* rather have a "write()" style interface (ie _copying_
> >> > bytes from user space into a newly allocated page that gets mapped)
> >> > than a "remap page" style interface
> > Something like that might work for the postcopy case; it doesn't work
> > for some of the other uses that need to stop a page being changed by the
> > guest, but then need to somehow get a copy of that page internally to QEMU,
> > and perhaps provide it back later.
> 
> I cannot parse this.  Which uses do you have in mind?  Is it for
> QEMU-specific or is it for other applications of userfaults?

> As long as the page is atomically mapped, I'm not sure what the
> difference from remap_anon_pages are (as far as the destination page is
> concerned).  Are you thinking of having userfaults enabled on the source
> as well?

What I'm talking about here is when I want to stop a page being accessed by the
guest, do something with the data in qemu, and give it back to the guest sometime
later.

The main example is: Memory pools for guests where you swap RAM between a series of
VM hosts.  You have to take the page out, send it over the wire, sometime later if
the guest tries to access it you userfault and pull it back.
(There's at least one or two companies selling something like this, and at least
one Linux based implementations with their own much more involved kernel hacks)

Dave
--
Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
