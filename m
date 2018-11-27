Return-Path: <linux-kernel-owner@vger.kernel.org>
MIME-Version: 1.0
References: <alpine.LSU.2.11.1811241858540.4415@eggly.anvils>
 <CAHk-=wjeqKYevxGnfCM4UkxX8k8xfArzM6gKkG3BZg1jBYThVQ@mail.gmail.com>
 <alpine.LSU.2.11.1811251900300.1278@eggly.anvils> <alpine.LSU.2.11.1811261121330.1116@eggly.anvils>
 <20181126205351.GM3065@bombadil.infradead.org> <20181127105602.GC16502@rapoport-lnx>
 <010001675613a406-89de05df-ccf6-4bfa-ae3b-6f94148d514a-000000@email.amazonses.com>
In-Reply-To: <010001675613a406-89de05df-ccf6-4bfa-ae3b-6f94148d514a-000000@email.amazonses.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 27 Nov 2018 08:58:30 -0800
Message-ID: <CAHk-=wisu7SHwHYo6TKo6t5CM6Da66jGsMgXKdrfNa-fDzdP5g@mail.gmail.com>
Subject: Re: [PATCHi v2] mm: put_and_wait_on_page_locked() while page is migrated
Content-Type: text/plain; charset="UTF-8"
Sender: linux-kernel-owner@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Cc: rppt@linux.ibm.com, Matthew Wilcox <willy@infradead.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, bhe@redhat.com, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, david@redhat.com, mgorman@techsingularity.net, David Herrmann <dh.herrmann@gmail.com>, Tim Chen <tim.c.chen@linux.intel.com>, kan.liang@intel.com, Andi Kleen <ak@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@gmail.com>, pifang@redhat.com, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 27, 2018 at 8:49 AM Christopher Lameter <cl@linux.com> wrote:
>
> A process has no refcount on a page struct and is waiting for it to become
> unlocked? Why? Should it not simply ignore that page and continue?

The problem isn't that you can just "continue".

You need to *retry*.

And you can't just busy-loop. You want to wait until the page state
has changed, and _then_ retry.

                  Linus
