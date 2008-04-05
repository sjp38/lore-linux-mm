From: Andrea Arcangeli <andrea@qumranet.com>
Subject: [ofa-general] Re: [patch 01/10] emm: mm_lock: Lock a process against
	reclaim
Date: Sat, 5 Apr 2008 02:41:27 +0200
Message-ID: <20080405004127.GG14784@duo.random>
References: <20080404223048.374852899@sgi.com>
	<20080404223131.271668133@sgi.com> <47F6B5EA.6060106@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <47F6B5EA.6060106@goop.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Christoph Lameter <clameter@sgi.com>
List-Id: linux-mm.kvack.org

On Fri, Apr 04, 2008 at 04:12:42PM -0700, Jeremy Fitzhardinge wrote:
> I think you can break this if() down a bit:
>
> 			if (!(vma->vm_file && vma->vm_file->f_mapping))
> 				continue;

It makes no difference at runtime, coding style preferences are quite
subjective.

> So this is an O(n^2) algorithm to take the i_mmap_locks from low to high 
> order?  A comment would be nice.  And O(n^2)?  Ouch.  How often is it 
> called?

It's called a single time when the mmu notifier is registered. It's a
very slow path of course. Any other approach to reduce the complexity
would require memory allocations and it would require
mmu_notifier_register to return -ENOMEM failure. It didn't seem worth
it.

> And is it necessary to mush lock and unlock together?  Unlock ordering 
> doesn't matter, so you should just be able to have a much simpler loop, no?

That avoids duplicating .text. Originally they were separated. unlock
can't be a simpler loop because I didn't reserve vm_flags bitflags to
do a single O(N) loop for unlock. If you do malloc+fork+munmap two
vmas will point to the same anon-vma lock, that's why the unlock isn't
simpler unless I mark what I locked with a vm_flags bitflag.
