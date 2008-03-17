Date: Mon, 17 Mar 2008 04:26:53 -0500
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] [0/18] GB pages hugetlb support
Message-Id: <20080317042653.d5a85911.pj@sgi.com>
In-Reply-To: <20080317258.659191058@firstfloor.org>
References: <20080317258.659191058@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, Christoph Lameter <clameter@sgi.com>, Ken Chen <kenchen@google.com>, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Andi wrote:
> I hacked in also cpuset support. It would be good if 
> Paul double checked that.

Well, from what I can see, Ken Chen wrote the code that deals with
constraints on hugetlb allocation.  So I'll copy him on this reply,
along with the other two subject matter experts I know of in this area,
Christoph Lameter and Adam Litke.

The following is the only cpuset related change I saw in this
patchset.  It looks pretty obvious to me ... just changing the code to
adapt to Andi's new 'struct hstate' for holding what had been global
hugetlb state.

@@ -1228,18 +1252,18 @@ static int hugetlb_acct_memory(long delt
 	 * semantics that cpuset has.
 	 */
 	if (delta > 0) {
-		if (gather_surplus_pages(delta) < 0)
+		if (gather_surplus_pages(h, delta) < 0)
 			goto out;
 
-		if (delta > cpuset_mems_nr(free_huge_pages_node)) {
-			return_unused_surplus_pages(delta);
+		if (delta > cpuset_mems_nr(h->free_huge_pages_node)) {
+			return_unused_surplus_pages(h, delta);
 			goto out;
 		}
 	}
 

Andi claimed, in one of his replies earlier on this thread, that there
were further interactions with cpusets and later patches in the set
that "Add basic support for more than one hstate in hugetlbfs
and partly Add support to have individual hstates for each hugetlbfs
mount", but I'm not understanding what that interaction is yet.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
